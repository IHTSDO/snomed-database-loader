#!/usr/bin/python
from __future__ import print_function
import py2neo, sys, base64, optparse, datetime

'''
Module:  snomed_g_neo4j_tools.py
Author:  Jay Pedersen, July 2016
Purpose: NEO4J utility commands -- eg 'run_cypher'.
Syntax and Semantics:
          python <pgm> run_cypher <filename> --neopw <pw>
'''

def run_cypher(arglist):
  # Parse command line
  opt = optparse.OptionParser()
  opt.add_option('--verbose',action='store_true')
  opt.add_option('--neopw64', action='store')
  opt.add_option('--neopw', action='store')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==1 and (opts.neopw or opts.neopw64)):
    print('Usage: command <cypherfile> --neopw <pw>'); sys.exit(1)
  if opts.neopw and opts.neopw64:
    print('Usage: only one of --neopw and --neopw64 may be specified')
    sys.exit(1)
  if opts.neopw64: # snomed_g v1.2, convert neopw64 to neopw
    opts.neopw = str(base64.b64decode(opts.neopw64),'utf-8') if sys.version_info[0]==3 else base64.decodestring(opts.neopw64) # py2
  n4jpw = opts.neopw
  cypher_fn = args[0]
  graph_db = py2neo.Graph(password=n4jpw) # 'http://localhost:7474/db/data/transaction/commit')
  # want LONG TIMEOUT for CSV loadering
  from py2neo.packages.httpstream import http
  http.socket_timeout = 1200 # JGP default was 30 on July 2016, this is 20 min I believe
  # Execute the CYPHER commands in the file
  command_lines = [ x.rstrip('\n').rstrip('\r').strip() for x in open(cypher_fn) ]
  succeeded, failed = 0, 0
  next_cmd = ''
  for idx,cmd in enumerate(command_lines):
    if opts.verbose: print('%d. %s' % (idx+1,cmd))
    if len(cmd)==0 or cmd.startswith('//'): continue # empty or comment
    next_cmd += cmd if len(next_cmd)==0 else ' '+cmd
    if next_cmd.rstrip()[-1] != ';': continue # dont sent until semicolon ends sequence of commands
    # dont' send if a RETURN '<message>';, just check for RETURN ' for now -- works with our scripts
    if next_cmd.startswith("""RETURN '"""): next_cmd = ''; continue
    if opts.verbose: print('Sending CYPHER:[%s]' % next_cmd)
    success = False
    cursor = None
    command_start = datetime.datetime.now()
    try:   cursor = graph_db.run(next_cmd).dump()
    except Exception as e: failed += 1; print('*** DB failure: command %d [%s] : [%s,%s]' % (idx+1,next_cmd,type(e),str(e))); pass
    else:  succeeded += 1; success = True
    if opts.verbose: command_end = datetime.datetime.now(); print('CYPHER execution time: %s' % (str(command_end-command_start),))
    next_cmd = ''
  print('SUCCESS (%d commands)' % succeeded if failed==0 else 'FAILED (%d commands failed, %d commands succeeded)' % (failed,succeeded) )
  sys.exit(failed) # CONVENTION -- exit program -- exit status is number of failures, zero if no failures
# END run_cypher

#----------------------------------------------------------------------------|
#                                MAIN                                        |
#----------------------------------------------------------------------------|

def parse_and_interpret(arglist):
  command_interpreters = [('run_cypher',run_cypher)]
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
