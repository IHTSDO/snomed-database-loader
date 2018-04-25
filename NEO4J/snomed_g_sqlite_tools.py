#!/usr/bin/python
from __future__ import print_function
import sys, optparse, sqlite3, datetime, csv, sqlite3, io

'''
Module: snomed_g_sqlite_tools.py
# Purpose: Implement various utility functions for processing RF2 DELTA files,
# Syntax and Semantics:
#          python snomed_g_sqlite_tools csv_import <sqlitefile> <sqlitetable> <csvfile>
#                ==> creates <sqlitetable> in delta.db SQLITE file
#          python <pgm> neo4j_import ...
'''

def db_data_prep(v):
  if sys.version_info[0]==3:
    return v
  else: # py2.7 support
    return v if isinstance(v,unicode) else unicode( (str(v) if isinstance(v, int) else v) , "utf-8")

#-------------------------------------------------------------------------------------
#  csv_import <sqlitefile> <sqlitetable> <csvfile> --fields 'f1<sep>f2<sep>...<sep>fn'
# 
# NOTE: definition flexible enough to support RRF files which are pipe-separated and
#       do not have a header line.  The names of the attributes are passed
#        via --fields <attribute-list>                                                
#------------------------------------------------------------------------------------

def csv_import(arglist):

  def parse_command_line(arglist):
    # --host 127.0.0.1  --sid deid --user heronloader --password <whatever> --port 1431
    # schema folder
    opt = optparse.OptionParser()
    opt.add_option('--primary_key',action='store',dest='primary_key')
    opt.add_option('--csvdelim',action='store',default=',',dest='csvdelim')
    opt.add_option('--logmodulo',action='store',type='int',default=0,dest='logmodulo')
    opt.add_option('--fields',action='store',dest='fields')
    opt.add_option('--exists',action='store_true')
    opt.add_option('--excessive_verbosity',action='store_true')
    opts, args = opt.parse_args(arglist)
    print(args)
    if len(args)!=3: print('Usage: command <sqlitefile> <csvfile>  <sqlitetable> [--primary_key X]'); sys.exit(1)
    if opts.csvdelim==r'\t': opts.csvdelim = '\t' # deal with TAB delimiter
    return args,opts

  # csv_import:
  # Parse command line
  args, opts = parse_command_line(arglist)
  sqlitefile, csvfile, sqlitetable = args

  print('csv delimiter is [%s]' % opts.csvdelim)
  # open CSV file (could be pipe-separated RRF file)
  f = io.open(csvfile,'r',encoding='utf-8')
  # determine field names -- either from header line in file or from --fields
  if opts.fields: # ASSUME this means there is no header line
    field_names = [x.strip('"') for x in opts.fields.split(opts.csvdelim)]
  else:  # ASSUME there is a header line in the file
    hdr = f.readline().rstrip('\n').rstrip('\r')
    field_names = [x.strip('"') for x in hdr.split(opts.csvdelim)]
  print(field_names)
  fields_d = {}
  for idx, nm in enumerate(field_names): fields_d[nm] = idx
  f.close()
  # create 'create table' statement with all fields text
  field_adds = []
  for nm in field_names:
    field_adds.append('%s text'%nm if opts.primary_key!=nm else '%s text primary key'%nm)
  
  conn = sqlite3.connect(sqlitefile)
  curs = conn.cursor()
  if not opts.exists:
    drop_sql_str = 'DROP TABLE IF EXISTS %s' % sqlitetable
    print(drop_sql_str)
    curs.execute(drop_sql_str)
    create_sql = 'create table %s ('%sqlitetable + ','.join(field_adds) + ');'
    print(create_sql)
    curs.execute(create_sql)
  # create "INSERT INTO <table> (<name1>, ...) VALUES (?, ...);"
  insert_sql = 'insert into %s ('%sqlitetable + ','.join(field_names) + ') VALUES (' + ','.join(['?']*len(field_names)) + ');'
  print(insert_sql)
  # process CSV file, insert rows into table
  reader = csv.reader(io.open(csvfile,'r',encoding='utf-8'), delimiter=opts.csvdelim)
  first = True
  rownum = 0
  lasttime = datetime.datetime.now()
  for row in reader:
      if first: first = False; continue # header line
      rownum += 1
      insert_values = [db_data_prep(row[idx]) for idx in range(len(field_names))]
      if opts.excessive_verbosity:
        print('%d. %s' % (rownum, str(insert_values)))
      curs.execute(insert_sql, insert_values)
      if opts.logmodulo!=0 and rownum % opts.logmodulo==0:
          curtime = datetime.datetime.now()
          deltatime = curtime - lasttime
          delta_seconds = deltatime.seconds # py 2.6, total_seconds() comes later?
          print('Inserted %d rows, delta seconds %d' % (rownum,delta_seconds))
          lasttime = curtime
  conn.commit()
  print('Processed %d rows' % rownum)
  return

#------------------------------------------------------------------------------------
#   neo4j_import <sqlitefile> <sqlitetable> --neo_pw <base64> --cypher <str>        |
#                --cypher_vbl <vbl> --list --count                                  |
#------------------------------------------------------------------------------------

def neo4j_import(arglist): # neo4j_import --new_pw <pwbase64> ...

  def parse_command_line(arglist):
    # <sqlite-file> <sqlite-table> --result --count
    opt = optparse.OptionParser()
    opt.add_option('--list',action='store_true',dest='list')
    opt.add_option('--count',action='store_true',dest='count')
    opt.add_option('--neo_pw',action='store',dest='neo_pw')
    opt.add_option('--cypher',action='store',dest='cypher') # eg: MATCH (n:ObjectConcept)-[r:ISA]-(b:ObjectConcept)
    opt.add_option('--cypher_file',action='store',dest='cypher_file')
    opt.add_option('--cypher_vbl',action='store',dest='cypher_vbl') # eg: r
    opt.add_option('--primary_key',action='store',default='',dest='primary_key')
    opt.add_option('--logmodulo',action='store',type='int',default=0,dest='logmodulo')
    opt.add_option('--add_end_node',action='store',dest='add_end_node')

    opts, args = opt.parse_args(arglist)
    if not (len(args)==2 and opts.neo_pw and (opts.cypher or opts.cypher_file) and opts.cypher_vbl):
      print('Usage: command <cypherfile> --neo_pw <base64> --cypher <str> --cypher_vbl <name> --list --count')
      sys.exit(1)
    if opts.cypher_file: opts.cypher = open(opts.cypher_file).read() # --cypher_file overrides --cypher
    return args,opts

  def execute_cypher(cypher_string,opts):
    command_list = [ x.rstrip('\n').rstrip('\r') for x in cypher_string.split('\n') if len(x) > 0]
    
    succeeded, failed = 0, 0
    for idx,cmd in enumerate(command_list):
      print('%d. %s' % (idx+1,cmd))
      cursor = None
      try:
        cursor = graph_db.run(cmd)
      except:
        print('DB Failure for [%s]' % cmd)
        failed += 1
      else:
        succeeded += 1
    # Report statistics
    print('%d commands succeeded' % succeeded)
    if failed>0: print('*** %d commands FAILED ***' % failed); sys.exit(1)
    return cursor

  def extract_property_names(cursor,vbl_name,opts):
    # NOTE: ONE result only, guaranteed by LIMIT 1
    property_names = []
    idx = 0
    while cursor.forward():
      idx += 1
      property_names = cursor.current()[vbl_name]
      # eg: [u'typeId', u'effectiveTime', u'active', ..., u'history']
      print('%d. %s' % (idx, str(property_names)))
      return property_names
    print('*** extract_property_names FAILED -- no result')
    return []

  def populate_sqlite_table(neo_cursor,opts,field_names,sqlite_cursor,sqlitetable):
    chunk_size = 10000 # 10,000 rows at a time added (reduce transaction cost)
    lasttime = datetime.datetime.now() # logmodulo processing needs a lasttime to exist
    # create "INSERT INTO <table> (<name1>, ...) VALUES (?, ...);"
    insert_sql = 'insert into %s ('%sqlitetable + ','.join(field_names) + ') VALUES (' + ','.join(['?']*len(field_names)) + ');'
    print(insert_sql)
    sqlite_cursor.execute('BEGIN') # BEGIN TRANSACTION
    rownum = 0; rows_in_transaction = 0
    while neo_cursor.forward():
      rownum += 1
      if not opts.add_end_node:
        insert_values = [db_data_prep(neo_cursor.current()['%s.%s' % (opts.cypher_vbl,x)]) for x in field_names]
      else:
        insert_values = [ db_data_prep(neo_cursor.current()['%s.%s' % (opts.cypher_vbl,x)]) for x in field_names[:-1] ] + \
                        [ db_data_prep(neo_cursor.current()[ field_names[-1] ]) ] # eg: destinationId vs r.destinationId
      sqlite_cursor.execute(insert_sql, insert_values)
      rows_in_transaction += 1
      if rows_in_transaction == chunk_size:
        for command in ['END','BEGIN']: sqlite_cursor.execute(command) # END TRANSACTION, BEGIN TRANSACTION
        rows_in_transaction = 0
      if opts.logmodulo!=0 and rownum % opts.logmodulo==0:
          curtime = datetime.datetime.now(); deltatime = curtime - lasttime; delta_seconds = deltatime.seconds # py 2.6, no total_seconds()
          print('Inserted %d rows, delta seconds %d' % (rownum,delta_seconds))
          lasttime = curtime
    # end -- processed all data from NEO4j
    sqlite_cursor.execute('END') # END TRANSACTION
    print('Total of %d result(s)' % rownum)

  def list_results(cursor,opts,property_names):
    idx = 0
    while cursor.forward():
      idx += 1
      #r = cursor.current()[opts.cypher_vbl]
      if opts.list:
        print(','.join(str(cursor.current()['%s.%s' % (opts.cypher_vbl,x)]) for x in property_names))
    print('Total of %d result(s)' % idx)

  # neo4j_import:
  args, opts = parse_command_line(arglist)
  sqlitefile, sqlitetable = args
  
  ''' Add the following if parse command and --watch specified
  watch_list = [ "httpstream", "py2neo.cypher", "py2neo.batch" ]
  for elem in watch_list: py2neo.watch(elem)
  '''
  
  import py2neo, base64
  n4jpw = base64.decodestring(opts.neo_pw)
  graph_db = py2neo.Graph(password=n4jpw) # 'http://localhost:7474/db/data/transaction/commit')
  
  # Query #1 -- determine keys(r)
  vbl_name = 'keys(%s)' % opts.cypher_vbl
  cypher_str = opts.cypher + ' return %s LIMIT 1' % vbl_name
  print(cypher_str)
  cursor = execute_cypher(cypher_str,opts)
  field_names = extract_property_names(cursor,vbl_name,opts)
  if opts.add_end_node: field_names.append(opts.add_end_node)
  # Connect to SQLITE database, create table
  sqlite_connection = sqlite3.connect(sqlitefile)
  sqlite_connection.isolation_level = None # allow for Transaction control, buffering rows before commit (performance)
  # see -- https://docs.python.org/2/library/sqlite3.html#sqlite3.Connection.isolation_level
  sqlite_cursor = sqlite_connection.cursor()
  drop_sql_str = 'DROP TABLE IF EXISTS %s' % sqlitetable
  print(drop_sql_str)
  sqlite_cursor.execute(drop_sql_str)
  # create 'create table' statement with all fields text
  field_adds = []
  for nm in field_names:
    field_adds.append('%s text'%nm if opts.primary_key!=nm else '%s text primary key'%nm)
  create_sql = 'create table %s ('%sqlitetable + ','.join(field_adds) + ');'
  print(create_sql)
  sqlite_cursor.execute(create_sql) # create table
  # Create query #2, returning all those keys for every matching object
  if not opts.add_end_node:
    cypher_str = opts.cypher + ' return ' + ','.join(['%s.%s' % (opts.cypher_vbl,x) for x in field_names])
  else:
    cypher_str = opts.cypher + ' return ' + ','.join(['%s.%s' % (opts.cypher_vbl,x) for x in field_names[:-1]])+\
                 ',' + 'endNode(%s).id as %s' % (opts.cypher_vbl,opts.add_end_node)
  print(cypher_str)
  
  # Query #2, find all objects and return all specified keys
  neo_cursor = execute_cypher(cypher_str,opts)
  #list_results(cursor,opts,field_names)
  populate_sqlite_table(neo_cursor,opts,field_names,sqlite_cursor,sqlitetable)
  
  # All done
  return

def parse_and_interpret(arglist):
  # compute_FSN or compute_history
  command_interpreters = [('csv_import',csv_import), ('neo4j_import',neo4j_import)]
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