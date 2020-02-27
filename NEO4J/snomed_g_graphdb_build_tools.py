#!/usr/bin/python
from __future__ import print_function
import csv, optparse, datetime, json, sys, re, os, base64, errno, io, sqlite3, subprocess
from subprocess import PIPE
import snomed_g_lib_rf2, snomed_g_lib_neo4j, snomedct_constants

'''
Module:  snomed_g_graphdb_build_tools.py
Author:  Jay Pedersen, July 2016
Purpose: Driver program that either creates or updates a SNOMED_G graph database.
Syntax and Semantics:
          python <pgm> db_build --release_type delta/snapshot/full --rf2 <location> --mode build/prep
                ==> creates cocncept_delta_FSN table in delta.db SQLITE file
                ==> accesses NEO4J graph at localhost
Example:
          python snomed_g_graphdb_build_tools.py \
             db_build --release_type full --mode build --action create \
                 --rf2 /cygdrive/c/sno/snomedct/SnomedCT_RF2Release_US1000124_20160301 \
                 --neopw abcdefgh
'''

# TIMING functions
def timing_start(timing_d, nm): timing_d[nm] = { 'start': datetime.datetime.now() }
def timing_end(timing_d, nm):   timing_d[nm]['end'] = datetime.datetime.now()
def show_timings(timestamps):
  for key in sorted(timestamps.keys()):
    delta = timestamps[key]['end'] - timestamps[key]['start']
    print('%-35s : %s' % (key, str(delta)))

if sys.platform not in ['cygwin','win32']: # Ubuntu/Mac
  def get_path(relpath, pathsep):
    return os.path.abspath(os.path.expanduser(relpath)).rstrip(pathsep)+pathsep
elif sys.platform == 'win32': # DOS, not cygwin, issue 'c:\\sno\\build\\us20160301_06/build.log'
  def get_path(relpath, pathsep):
    return os.path.abspath(os.path.expanduser(relpath)).replace('\\',pathsep).rstrip(pathsep)+pathsep
else: # cygwin
  def get_path(relpath, pathsep): # Need t:/neo/data/sc_20140731/snomed_g_rconcept_... from '/cygdrive/t/neo/data/...
    s1 =  os.path.realpath(os.path.expanduser(relpath)) # was abspath, realpath expands symlink
    m = re.match(r'/cygdrive/(.)/(.*)', s1)
    if m:  # cygwin full path
      s = '%s:/%s' % (m.group(1),m.group(2))
      if s[-1] != pathsep: s += pathsep
    else:
      print('*** unable to translate path <%s> ***', relpath); sys.exit(1)
    return s

class StatusDb():
  def __init__(self, filename="build_status.db"):
    self.dbfilename = filename
    db = sqlite3.connect(self.dbfilename)
    c = db.cursor()
    c.execute('CREATE TABLE IF NOT EXISTS seq (name text primary key, nextval integer)')
    try:    c.execute('''insert into seq values ('BUILD', 0)''')
    except: pass
    else:   print('sequence did not exist, primed')
    c.execute('CREATE TABLE IF NOT EXISTS build (\
          seq INTEGER, \
          step TEXT, \
          command TEXT, \
          result TEXT, \
          status INTEGER, \
          seconds INTEGER, \
          output TEXT, \
          error TEXT, \
          start TEXT, \
          end TEXT \
          )' )
    db.commit()
    c.close()
    db.close() # keep db closed most of the time

  def get_next_sequence_number(self):
      # obtain sequence number
      db = sqlite3.connect(self.dbfilename)
      c = db.cursor()
      c.execute("update seq set nextval=nextval+1 where name='BUILD'")
      db.commit()
      nextval_list = c.execute("select nextval from seq where name='BUILD'").fetchall()
      return nextval_list[0][0] # the next sequence number

  def add_record(self, seq, step, command, result, status, seconds, output, error, start, end):
      db = sqlite3.connect(self.dbfilename)
      c = db.cursor()
      # insert into build table
      c.execute('INSERT INTO build(seq, step, command, result, status, seconds, output, error, start, end) \
                  VALUES(?,?,?,?,?,?,?,?,?,?)', (seq, step, command, result, status, seconds, output, error, str(start), str(end)))
      db.commit()
      c.close()
      db.close() # keep db closed most of the time

class save_and_report_results():
  def __init__(self, DB, seqnum, stepnames, results_d, logfile): # conststructor

    def set_step_variables(stepname):
      self.result_s = self.results_d[stepname].get('result','<NA>')
      self.status = self.results_d[stepname].get('status',-100)
      self.expected_status = self.results_d[stepname].get('expected_status',0)
      self.elapsed_time = self.results_d[stepname].get('elapsed_time',-1)
      self.seconds = self.elapsed_time.seconds # could use .total_seconds(), eg: 7.193 versus 7
      self.output = self.results_d[stepname].get('STDOUT','')
      if sys.version_info[0]==2: self.output.decode('utf-8') # py2.7 support, py3 all string processing is unicode
      self.error = self.results_d[stepname].get('STDERR','')
      if sys.version_info[0]==2: self.error.decode('utf-8') # py2.7 support
      self.cmd_start_s = str(self.results_d[stepname].get('cmd_start','<NI>'))
      self.cmd_end_s = str(self.results_d[stepname].get('cmd_end','<NI>'))
      self.command = self.results_d[stepname].get('command','<NI>')
    # end set_step_variables

    # constructor:
    self.DB = DB # StatusDb object (sqlite3 database)
    self.seqnum = seqnum # Backup sequence number, first backup ever is #1, second #2, etc
    self.results_d = results_d
    self.logfile = logfile
    self.stepnames = [x for x in stepnames if x in self.results_d]
    self.procedure_worked = all(self.results_d[stepname]['result'] == 'SUCCESS' for stepname in self.stepnames)
    self.failed_steps = [x for x in self.stepnames if self.results_d[x]['result'] != 'SUCCESS']
    # Get to work -- Write result to DB, see if everything worked
    for stepname in self.stepnames:
      set_step_variables(stepname)
      # Write the status to the database
      self.DB.add_record(self.seqnum, stepname, self.command, self.result_s, self.status, self.seconds, self.output, self.error,
                self.cmd_start_s, self.cmd_end_s)
    # SUMMARY display
    print(file=self.logfile)
    for f in [self.logfile, sys.stdout]: print('RESULT: %s' % 'SUCCESS' if self.procedure_worked else 'FAILED (steps: %s)' % str(self.failed_steps), file=f)
    print(file=self.logfile)
    print('SUMMARY:', file=self.logfile)
    print(file=self.logfile)
    for stepname in self.stepnames:
      set_step_variables(stepname)
      print('%-25s : %-25s, duration:%s' % (stepname, self.result_s, str(self.elapsed_time)), file=self.logfile)
    # DETAIL display
    print(file=self.logfile)
    print('DETAILS:', file=self.logfile)
    print(file=self.logfile)
    print('Backup sequence number: %d' % self.seqnum, file=self.logfile)
    for stepname in self.stepnames:
      set_step_variables(stepname)
      print('step:[%s],result:[%s],command:[%s],status/expected:%d/%d,duration:%s,output:[%s],error:[%s],cmd_start:[%s],cmd_end:[%s]' %
            (stepname, self.result_s, self.command, self.status, self.expected_status, str(self.elapsed_time),
             self.output, self.error, self.cmd_start_s, self.cmd_end_s), file=self.logfile)
    return # DONE
# END save_and_report_results class

#-------------------------------------------------------------------------------|
#   db_build --action create --rf2 <dir> --release_type delta --neopw <pw>    |
#-------------------------------------------------------------------------------|

def db_build(arglist):
  saved_pwd = os.getcwd()
  opt = optparse.OptionParser()
  opt.add_option('--rf2',action='store')
  opt.add_option('--release_type', action='store', dest='release_type', choices=['delta','snapshot','full'])
  opt.add_option('--action', action='store', default='create', choices=['create','update'])
  opt.add_option('--neopw64', action='store')
  opt.add_option('--neopw', action='store')
  opt.add_option('--mode', action='store', default='build',
                 choices=['build','prep','make_csvs','run_cypher','validate']) # build is end-to-end, others are subsets
  opt.add_option('--logfile', action='store')
  opt.add_option('--output_dir', action='store', default='.')
  opt.add_option('--relationship_file', action='store', default='Relationship')
  opt.add_option('--language_code', action='store', default='en',
                 choices=['en','en-us', 'en-US', 'en-GB'])
  opt.add_option('--language_name', action='store', default='Language')
  opt.add_option('--prep_only', action='store_true')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==0 and opts.rf2 and opts.release_type and (opts.neopw or opts.neopw64)):
    print('Usage: db_build --rf2 <dir> --release_type snapshot/full --neopw <pw>')
    sys.exit(1)
  if opts.neopw and opts.neopw64:
    print('Usage db_build, only one of --neopw and --neopw64 may be specified')
    sys.exit(1)
  if opts.neopw64: # snomed_g v1.2, convert neopw64 to neopw
      opts.neopw = str(base64.b64decode(opts.neopw64),'utf-8') if sys.version_info[0]==3 else base64.decodestring(opts.neopw64) # py2
  # file path separator
  pathsep = '/'
  # make sure output directory exists and is empty
  opts.output_dir = get_path(opts.output_dir, pathsep)
  if not (os.path.isdir(opts.output_dir) and len(os.listdir(opts.output_dir)) == 0):
    print('*** Output directory [%s] isn\'t empty or doesn\'t exist ***' % opts.output_dir)
    sys.exit(1)
  # make sure a Terminology folder exists in the opts.rf2 folder
  if not (os.path.isdir(opts.rf2) and 'Terminology' in os.listdir(opts.rf2)):
    print('*** The --rf2 option [%s] must specify a folder, which must contain a Terminology subfolder' % opts.rf2)
    sys.exit(1)
  # open logfile
  logfile = open(opts.output_dir+'build.log', 'w') if not opts.logfile else \
            (sys.output if opts.logfile == '-' else open(opts.logfile, 'w'))
  #---------------------------------------------------------------------------
  # Determine SNOMED_G bin directory, where snomed_g_rf2_tools.py exists, etal
  #---------------------------------------------------------------------------
  # determine snomed_g_bin -- bin directory where snomed_g_rf2_tools.py exists in, etc -- try SNOMED_G_HOME, SNOMED_G_BIN env vbls
  # ... ask directly if these variables don't exist
  snomed_g_bin = os.environ.get('SNOMED_G_BIN',None) # unlikely to exist, but great if it does
  if not snomed_g_bin:
    snomed_g_home = os.environ.get('SNOMED_G_HOME',None)
    if snomed_g_home:
      snomed_g_bin = get_path(snomed_g_home, pathsep) + 'bin'
    else:
      snomed_g_bin = get_path(os.path.dirname(os.path.abspath(__file__)), pathsep) # default to python script dir
  validated = False
  while not validated:
    if len(snomed_g_bin)==0:
      snomed_g_bin = (input if sys.version_info[0]==3 else raw_input)\
                      ('Enter SNOMED_G bin directory path where snomed_g_rf2_tools.py exists: ').rstrip(pathsep)
    else: # try to validate, look for snomed_g_rf2_tools.py
      target_file = snomed_g_bin+pathsep+'snomed_g_rf2_tools.py'
      validated = os.path.isfile(target_file)
      if not validated: print('Cant find [%s]' % target_file); snomed_g_bin = ''
  snomed_g_bin = get_path(snomed_g_bin, pathsep)
  print('SNOMED_G bin directory [%s]' % snomed_g_bin)
  # db_build ==> connect to NEO4J, make sure information given is good
  if opts.mode=='build': neo4j = snomed_g_lib_neo4j.Neo4j_Access(opts.neopw)
  # Connect to RF2 files, make sure rf2 directory given is good
  rf2_folders = snomed_g_lib_rf2.Rf2_Folders(opts.rf2, opts.release_type, opts.relationship_file, opts.language_code)
  # Build
  # open SQLITE database
  DB = StatusDb(os.path.abspath(opts.output_dir.rstrip(pathsep)+pathsep+'build_status.db'))

  # create YYYYMMDD string
  d = datetime.datetime.now() # determine current date
  yyyymmdd = '%04d%02d%02d' % (d.year,d.month,d.day)
  job_start_datetime = datetime.datetime.now()

  # Commands needed to Create/Update a SNOMED_G Graph Database
  #   NOTE: Default mode is all-operations, so JOB_START and JOB_END to not have a mode specified
  commands_d = {
    'JOB_START' :
        {'stepname': 'JOB_START',
         'log':      'JOB-START(action:[%s], mode:[%s], release_type:[%s], rf2:[%s], date:[%s])' \
                          % (opts.action, opts.mode, opts.release_type, opts.rf2, yyyymmdd)},
    'FIND_ROLENAMES':
        {'stepname': 'FIND_ROLENAMES',
         'cmd':      'python %s/snomed_g_rf2_tools.py find_rolenames --release_type %s --rf2 %s --language_code %s --language_name %s' \
                         % (snomed_g_bin, opts.release_type, opts.rf2, opts.language_code, opts.language_name),
         'mode':     ['build','prep','make_csvs','validate']},
    'FIND_ROLEGROUPS':
        {'stepname': 'FIND_ROLEGROUPS',
         'cmd':      'python %s/snomed_g_rf2_tools.py find_rolegroups --release_type %s --rf2 %s --language_code %s --language_name %s' \
                         % (snomed_g_bin,opts.release_type,opts.rf2,opts.language_code,opts.language_name),
         'mode':     ['build','prep','make_csvs']},
    'MAKE_CONCEPT_CSVS':
        {'stepname': 'MAKE_CONCEPT_CSVS',
         'cmd':      'python %s/snomed_g_rf2_tools.py make_csv --element concept --release_type %s --rf2 %s --neopw %s --action %s --relationship_file %s --language_code %s --language_name %s' \
                         % (snomed_g_bin, opts.release_type, opts.rf2, opts.neopw, opts.action, opts.relationship_file, opts.language_code, opts.language_name),
         'mode':     ['build','prep','make_csvs','validate']},
    'MAKE_DESCRIPTION_CSVS':
        {'stepname': 'MAKE_DESCRIPTION_CSVS',
         'cmd':      'python %s/snomed_g_rf2_tools.py make_csv --element description --release_type %s --rf2 %s --neopw %s --action %s --relationship_file %s --language_code %s --language_name %s' \
                         % (snomed_g_bin, opts.release_type, opts.rf2, opts.neopw, opts.action, opts.relationship_file, opts.language_code, opts.language_name),
         'mode':     ['build','prep','make_csvs','validate']},
    'MAKE_ISA_REL_CSVS':
        {'stepname': 'MAKE_ISA_REL_CSVS',
         'cmd':      'python %s/snomed_g_rf2_tools.py make_csv --element isa_rel --release_type %s --rf2 %s --neopw %s --action %s --relationship_file %s --language_code %s --language_name %s' \
                         % (snomed_g_bin, opts.release_type, opts.rf2, opts.neopw, opts.action, opts.relationship_file, opts.language_code, opts.language_name),
         'mode':     ['build','prep','make_csvs','validate']},
    'MAKE_DEFINING_REL_CSVS':
        {'stepname': 'MAKE_DEFINING_REL_CSVS',
         'cmd':      'python %s/snomed_g_rf2_tools.py make_csv --element defining_rel --release_type %s --rf2 %s --neopw %s --action %s --relationship_file %s --language_code %s --language_name %s' \
                         % (snomed_g_bin, opts.release_type, opts.rf2, opts.neopw, opts.action, opts.relationship_file, opts.language_code, opts.language_name),
         'mode':     ['build','prep','make_csvs','validate']},
    'TEMPLATE_PROCESSING':
        {'stepname': 'TEMPLATE_PROCESSING',
         'cmd':      'python %s/snomed_g_template_tools.py instantiate %s/snomed_g_graphdb_cypher_%s.template build.cypher --rf2 %s --release_type %s' \
                         % (snomed_g_bin, snomed_g_bin, ('create' if opts.action=='create' else 'update'), opts.rf2, opts.release_type),
         'mode':     ['build','prep']},
    'CYPHER_EXECUTION':
        {'stepname': 'CYPHER_EXECUTION',
         'cmd':      'python %s/snomed_g_neo4j_tools.py run_cypher build.cypher --verbose --neopw %s' \
                         % (snomed_g_bin, opts.neopw),
         'mode':     ['build','run_cypher']},
    'CHECK_RESULT':
        {'stepname': 'CHECK_RESULT',
         'cmd':      'python %s/snomed_g_neo4j_tools.py run_cypher %s/snomed_g_graphdb_update_failure_check.cypher --verbose --neopw %s' \
                         % (snomed_g_bin, snomed_g_bin, opts.neopw),
         'mode':     ['build','run_cypher']},
    'JOB_END':
        {'stepname': 'JOB_END',
         'log':      'JOB-END'}
  }

  command_list_db_build = [ commands_d[x] for x in
                            ['JOB_START',
                             'FIND_ROLENAMES',
                             'FIND_ROLEGROUPS',
                             'MAKE_CONCEPT_CSVS',
                             'MAKE_DESCRIPTION_CSVS',
                             'MAKE_ISA_REL_CSVS',
                             'MAKE_DEFINING_REL_CSVS',
                             'TEMPLATE_PROCESSING',
                             'CYPHER_EXECUTION',
                             'CHECK_RESULT',
                             'JOB_END'] ]

  command_list_db_build_prep = [commands_d[x] for x in
                            ['JOB_START',
                             'FIND_ROLENAMES',
                             'FIND_ROLEGROUPS',
                             'MAKE_CONCEPT_CSVS',
                             'MAKE_DESCRIPTION_CSVS',
                             'MAKE_ISA_REL_CSVS',
                             'MAKE_DEFINING_REL_CSVS',
                             'TEMPLATE_PROCESSING',
                             'JOB_END'] ]

  # OLD --     #{'stepname':'CYPHER_EXECUTION',       'cmd':'%s/neo4j-shell -localhost -file build.cypher' % neo4j_bin, 'mode':['build','run_cypher']},
  command_list = command_list_db_build if not opts.prep_only else command_list_db_build_prep
  stepnames = [x['stepname'] for x in command_list] # list of dictionaries
  seqnum = DB.get_next_sequence_number()
  # Execute commands (BUILD)
  results_d = {}
  for command_d in command_list:
    # extract from tuple
    stepname, cmd, logmsg, expected_status, mode_requirement = \
      command_d['stepname'], command_d.get('cmd',None), command_d.get('log',None), command_d.get('expected_status',0), command_d.get('mode', None)
    if mode_requirement and opts.mode not in mode_requirement: continue # eg: NEO4J execution only in build mode
    results_d[stepname] = {}
    cmd_start = datetime.datetime.now() if stepname!='JOB_END' else job_start_datetime  # start timer
    status = -1
    should_break = False
    results_d[stepname]['result'] = 'SUCCESS' # assumption of success until failure determined
    results_d[stepname]['expected_status'] = expected_status
    results_d[stepname]['command'] = cmd
    print(stepname)
    print(stepname, file=logfile) # indicate to user what step we are on
    if logmsg: # no command to execute in a separate process
      results_d[stepname]['status'] = 0
      results_d[stepname]['STDOUT'] = logmsg # LOG everything after 'LOG:'
      output, err = '', ''
    else: # execute command (cmd) in subprocess
      print(cmd, file=logfile)
      try:
        #p = subprocess.Popen(cmd, shell=True,stdin=PIPE, stdout=PIPE, stderr=PIPE)
        #output, err = p.communicate(b"")
        #status = p.returncode
        cmd_as_list = cmd.split(' ')
        if opts.output_dir != '.': os.chdir(opts.output_dir) # move to output_dir, to start subprocess
        subprocess.check_call(cmd_as_list, stdout=logfile, stderr=logfile)
        if opts.output_dir != '.': os.chdir(saved_pwd) # get back (popd)
        status = 0 # if no exception -- status is zero
      except subprocess.CalledProcessError as e:
        status = e.returncode
        results_d[stepname]['status'] = status
        if status != expected_status:
          results_d[stepname]['result'] = 'FAILED (STATUS %d)' % status
          should_break = True
        pass # might be fine, should_break controls termination
      except: # NOTE: result defaulted to -1 above
        results_d[stepname]['result'] = 'EXCEPTION occured -- on step [%s], cmd [%s]' % (stepname,cmd)
        should_break = True
        pass
      else: # no exception
        results_d[stepname]['status'] = status
        if status != expected_status:
          results_d[stepname]['result'] = 'FAILED (STATUS %d)' % status
          should_break = True # no steps are optional, terminate now
    # Book-keeping
    cmd_end = datetime.datetime.now() # stop timer
    results_d[stepname]['elapsed_time'] = cmd_end-cmd_start
    if len(output) > 0: results_d[stepname]['STDOUT'] = output.replace('\n','<EOL>')
    if len(err) > 0: results_d[stepname]['STDERR'] = err.replace('\n','<EOL>')
    results_d[stepname]['cmd_start'] = cmd_start
    results_d[stepname]['cmd_end'] = cmd_end

    if should_break: break
  # Write results to the database
  save_and_report_results(DB, seqnum, stepnames, results_d, logfile)

  # Done
  sys.exit(0)
# END db_build

#----------------------------------------------------------------------------|
#                                MAIN                                        |
#----------------------------------------------------------------------------|

def parse_and_interpret(arglist):
  command_interpreters = [('db_build',db_build)]
  command_names = [x[0] for x in command_interpreters]
  if len(arglist) < 1: print('Usage: python <cmd> %s ...' % '[one of %s]' % ','.join(command_names)); sys.exit(1)
  # DEMAND that arglist[0] be one of the sub-commands
  command_name = arglist[0]
  try: command_index = command_names.index(command_name)
  except: print('Usage : python <cmd> %s ...' % '[one of %s]' % ','.join(command_names)); sys.exit(1)
  command_interpreters[command_index][1](arglist[1:]) # call appropriate interpreter

# MAIN
parse_and_interpret(sys.argv[1:]) # causes sub-command processing to occur as well
sys.exit(0)
