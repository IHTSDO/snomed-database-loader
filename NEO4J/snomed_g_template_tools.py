#!/usr/bin/python
from __future__ import print_function
import sys, os, re, optparse
import snomed_g_lib_rf2

'''
Module: snomed_g_template_tools.py
Concept: translate template file using configuration file information
         eg: replace <<<release_date>>> by 20140731, depending on config.
Supported tags:
         <<<X>>>, where X is one of the keys in the config file,
         such as <<<release_date>>> since "release_date" is configured.
Syntax:  cmd <template_file> <output_file>
Version 1.1 Jay Pedersen, July 2016.   Version created to match rf2_tools.
Author:  Jay Pedersen, University of Nebraska, Jan 8, 2015
'''

if sys.platform not in ['cygwin']: # Ubuntu/Mac
  def get_path(relpath, os_pathsep):
    return os.path.abspath(os.path.expanduser(relpath)).rstrip(os_pathsep)+os_pathsep
else: # cygwin
  def get_path(relpath, os_pathsep): # Need t:/neo/data/sc_20140731/snomed_g_rconcept_... from '/cygdrive/t/neo/data/...
    s1 =  os.path.realpath(os.path.expanduser(relpath)) # was abspath, realpath expands symlink
    m = re.match(r'/cygdrive/(.)/(.*)', s1)
    if m:  # cygwin full path
      s = '%s:/%s' % (m.group(1),m.group(2))
      if s[-1] != os_pathsep: s += os_pathsep
    else:
      print('*** unable to translate path <%s> ***', relpath); sys.exit(1)
    return s

def instantiate(arglist):
  # instantiate:
  # PARSE COMMAND
  # syntax: instantiate <template-file> <outfile>
  opt = optparse.OptionParser()
  opt.add_option('--rf2',action='store',dest='rf2')
  opt.add_option('--release_type', action='store', dest='release_type', choices=['delta','snapshot','full'])
  opt.add_option('--verbose',action='store_true',dest='verbose')
  opt.add_option('--action', action='store', dest='action', default='create', choices=['create','update'])
  opts, args = opt.parse_args(arglist)
  if not (len(args)==2 and opts.rf2 and opts.release_type):
    print('Usage: intantiate <template-file> <output-file> --rf2 <dir> --release_type {Full,Snapshot,Delta}'); sys.exit(1)
  template_file, output_file = args
  # Connect to RF2 files
  rf2_folders = snomed_g_lib_rf2.Rf2_Folders(opts.rf2, opts.release_type)
  # Information for creating the CSV files
  attributes_by_file = snomed_g_lib_rf2.Rf2_Attributes_per_File()
  # CONFIGURATION
  config = {}
  config['terminology_dir'] = rf2_folders.get_terminology_dir()
  config['release_date'] = rf2_folders.get_release_date()
  config['release_center'] = rf2_folders.get_release_center()
  config['output_dir'] = './'

  # Process template file
  fout = open(output_file, 'w')
  release_date = config['release_date'].strip()
  release_center = config.get('release_center', 'INT')
  os_pathsep = config.get('os_pathsep', '/') # JGP 2015/10/07, no default previously
  output_dir = get_path(config['output_dir'], os_pathsep)
  if sys.platform=='win32': output_dir = output_dir.replace('\\','/') # JGP 2016/07/30 -- issue "c:\sno\build\us20160301/defining_rel_edge_rem.csv"
  terminology_dir = get_path(config['terminology_dir'], os_pathsep)
  config_file_suffix = '%s_%s' % (release_center, release_date)
  file_protocol = 'file:///' if sys.platform in ['cygwin','win32','darwin'] else 'file:' # ubuntu is else case
  # NOTE: can result in 'file:////Users/<rest>' on Mac, replace by 'file:///Users/<rest>'
  # INSTANTIATION PT1 -- PROCESS FILES IN TEMPLATE, REPLACING TEMPLATES WITH INSTANTIATED VALUES
  for line in [x.rstrip('\n').rstrip('\r') for x in open(template_file)]:
      line = line.replace('<<<release_date>>>', release_date) \
                 .replace('<<<output_dir>>>', output_dir) \
                 .replace('<<<terminology_dir>>>', terminology_dir) \
                 .replace('<<<config_file_suffix>>>', config_file_suffix) \
                 .replace('<<<file_protocol>>>', file_protocol) \
                 .replace('file:////','file:///')
      print(line, file=fout)

  # INSTANTIATION PT2 -- DEFINING RELATIONSHIPS PROCESSING
  
  #                    Handle NEW defining relationships
  # Data source (for new defining relationships):
  #     <output_dir>/defining_rels_new_sorted.csv file
  #     id,active,sctid,rolegroup,typeId,rolename,destinationId,effectiveTime,
  #         moduleId,characteristicTypeId,modifierId,history
  #     4661958023,1,471280008,1,FINDING_SITE,589001,20140731,
  #         900000000000207008,900000000000011006,900000000000451002,
  # Algorithm:
  # NOTE: already sorted by rolename, so all FINDING_SITE elements together, etc
  #       ./snomed_sort_csv.py --fields 'rolename' --string
  #          defining_rels_new.csv defining_rels_new_sorted.csv
  # ==> create separate files for each defining-relationship type that
  #     is found, eg: DR_<snomedct-code>_new.csv
  # ==> add CYPHER code to process the created files and add the 
  #     defining relationships.
  
  with open(output_dir+'used_roles.csv') as f:
    for idx,line in enumerate(x.rstrip('\n').rstrip('\r') for x in f):
      if idx==0: continue # typeId,rolename
      typeId, rolename = line.split(',')
      # create CYPHER to load the file and add the relationships to ROLE_GROUP nodes
      # JGP 2017-10-31.  Use a 2-step procedure for creating the defining relationships,
      #   to support systems with smaller amounts of memory (use smaller transactions).
      #   The first step creates any necessary role groups, and the second step creates
      #   the defining relationship edges from role groups to the specified target concepts.
      print('// %s defining relationships' % rolename,file=fout)
      print('''RETURN 'NEW Defining relationships of type %s';''' % rolename,file=fout)
      print(file=fout)
      load_csv_line = ('LOAD CSV with headers from "%s%sDR_%s_new.csv" as line' % (('file:///' if sys.platform in ['cygwin','win32','darwin'] else 'file:'),output_dir,typeId)).replace('file:////','file:///')
      print(load_csv_line,file=fout)
      print('CALL {',file=fout)
      print('  with line ',file=fout)
      print('  MERGE (rg:RoleGroup { sctid: line.sctid, rolegroup: line.rolegroup })',file=fout)
      print(' } IN TRANSACTIONS OF 200 ROWS;',file=fout)
      print(file=fout)
      print('// Add defining relationship edge in 2nd step, Java memory issue',file=fout)
      load_csv_line = ('LOAD CSV with headers from "%s%sDR_%s_new.csv" as line' % (('file:///' if sys.platform in ['cygwin','win32','darwin'] else 'file:'),output_dir,typeId)).replace('file:////','file:///')
      print(load_csv_line,file=fout)
      print('CALL {',file=fout)
      print('  with line ',file=fout)
      print('  MATCH (rg:RoleGroup { sctid: line.sctid, rolegroup: line.rolegroup })',file=fout)
      print(  'WITH line,rg ',file=fout)
      print('  MATCH (c:ObjectConcept { sctid: line.destinationId })',file=fout)
      print('  MERGE (rg)-[:%s { id: line.id, active: line.active, sctid: line.sctid,' % rolename,file=fout)
      print('                               typeId: line.typeId,',file=fout)
      print('                               rolegroup: line.rolegroup, effectiveTime: line.effectiveTime,',file=fout)
      print('                               moduleId: line.moduleId, characteristicTypeId: line.characteristicTypeId,',file=fout)
      print('                               modifierId: line.modifierId,',file=fout)
      print('                               history: line.history }]->(c)',file=fout)
      print(' } IN TRANSACTIONS OF 200 ROWS;',file=fout)
  # close CSV, wrap up
  print('// Finito',file=fout)
  fout.close()
  return

def parse_and_interpret(arglist):
  command_interpreters = [('instantiate',instantiate)]
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
