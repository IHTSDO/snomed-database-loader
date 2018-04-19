#!/usr/bin/python
from __future__ import print_function
import py2neo, sys,  json, anydbm, os, optparse, base64
from timeit import default_timer as timer
import snomed_g_lib_neo4j

# -----------------------------------------------------------------------------
# Module:  snomed_g_TC_tools.py
# Purpose: Compute Transitive-Closure (currently only from Graph using py2neo).
#          Given a NEO4J database with SNOMED_G schema,
#          generate a transitive closure file.
#          Uses REST API to NEO4J, via py2neo library.
# Syntax:  python <pgm> <outputfile> <date>
# Date:    syntax YYYYMMDD
# Eg:      python snomed_g_TC_tools.py TC.txt 20140131
# Output:  SPecified transitive closure file, one parent-child def per line:
#          <parent>,<child>
# Algorithm:
#          DAG_DFTC algorithm for generation of Transitive Closure.
#          ACM Transactions on Database Systems, Vol. 18, No. 3, Sep. 1993,
#          Pages: 512 - 576.
# Author:  Jay Pedersen, University of Nebraska, Aug 25, 2015
# -----------------------------------------------------------------------------

#---------------------------------------------------------------------------------|
#                                   TC_from_RF2                                   |
#---------------------------------------------------------------------------------|

def TC_from_RF2(arglist):
  #-------------------------------------------------------------------------------
  # build_ISA_graph(children,filename)
  # Concept: Reads ISA edges from relationships file, stores in the children hash
  #-------------------------------------------------------------------------------
  def build_ISA_graph(children,relationships_filename):
    global ISA_edges
    for idx,line in enumerate(x.rstrip('\n').rstrip('\r') for x in open(relationships_filename)):
      # line -- [0]id,[1]effectiveTime,[2]active,[3]moduleId,[4]sourceId,[5]destinationId,
      #         [6]relationshipGroup,[7]typeId,[8]characteristicTypeId,[9]modifierId
      if idx==0: continue # ignore column names
      values = line.split('\t')
      active, sourceId, destinationId, typeId = \
                                  (values[2], values[4], values[5], values[7])
      if typeId=="116680003" and active=="1":        # active ISA relationship
        if destinationId not in children:            # parent discovered
          children[destinationId] = set([sourceId])  # 1st child, create list
        else:
          children[destinationId].add(sourceId)      # nth child, add to set
    return # done
  
  #-------------------------------------------------------------------------------
  # compute_TC_table(startnode,children,descendants,visited)
  #-------------------------------------------------------------------------------
  # Based on a method described in "Transitive Closure Algorithms
  # Based on Graph Traversal" by Yannis Ioannidis, Raghu Ramakrishnan, and Linda Winger,
  # ACM Transactions on Database Systems, Vol. 18, No. 3, September 1993,
  # Pages: 512 - 576.
  # Simplified version of their "DAG_DFTC" algorithm.
  #-------------------------------------------------------------------------------
  # 
  def compute_TC_table(startnode,children,descendants,visited): # recursively depth-first traverse the graph.
    visited.add(startnode)
    descendants[startnode] = set([]) # no descendants yet
    if startnode not in children: return # no children case, leaf nodes
    for childnode in children[startnode]: # for all the children of the startnode
      if childnode not in visited:  # if not yet visited (Note: DFS traversal)
        compute_TC_table(childnode,children,descendants,visited) # recursively visit the childnode, set descendants
      for descendant in list(descendants[childnode]): # each descendant of childnode
        descendants[startnode].add(descendant) # mark descendants of startnode
      descendants[startnode].add(childnode) # mark immediate child of startnode
    return
  
  def print_TC_table(descendants, outfile_name):
    fout = open(outfile_name, 'w')
    for startnode in descendants.keys():
      for endnode in list(descendants[startnode]):
        print('%s,%s' % (startnode,endnode), file = fout)
    fout.close()
    return
  
  # TC_from_RF2:
  # command line parsing
  if len(arglist)!=2:
   print('Syntax: cmd TC_from_RF2 <relationshipsfilename-in> <TCfilename-out>')
   sys.exit(1)
  relationships_filename, output_TC_filename = arglist[0], arglist[1]
  
  # Compute TC table from ISA relationships, output to specified file.
  children, visited, descendants, concept_node = ({}, set(), {}, "138875005") # init
  build_ISA_graph(children, relationships_filename) # build 'children' hash
  compute_TC_table(concept_node, children, descendants, visited)
  print_TC_table(descendants, output_TC_filename)
  
  # All done
  return

#---------------------------------------------------------------------------------|
#                                   TC_from_graph                                 |
#---------------------------------------------------------------------------------|

def TC_from_graph(arglist):
  #-------------------------------------------------------------------------------
  # build_ISA_graph(children,filename)
  # Concept: Reads ISA edges from relationships file, stores in the children hash
  #-------------------------------------------------------------------------------
  def build_ISA_graph(children,isa_rels):
    for idvalue in isa_rels.keys():
      isa_map = isa_rels[idvalue]
      active, sourceId, destinationId = isa_map['active'], isa_map['sourceId'], isa_map['destinationId']
      if active=='1': # active ISA relationship
        if destinationId not in children:            # parent discovered
          children[destinationId] = set([sourceId])  # 1st child, create list
        else:
          children[destinationId].add(sourceId)      # nth child, add to set
    return # done
  
  #-------------------------------------------------------------------------------
  # compute_TC_table(startnode,children,descendants,visited)
  #-------------------------------------------------------------------------------
  # Based on a method described in "Transitive Closure Algorithms
  # Based on Graph Traversal" by Yannis Ioannidis, Raghu Ramakrishnan, and Linda Winger,
  # ACM Transactions on Database Systems, Vol. 18, No. 3, September 1993,
  # Pages: 512 - 576.
  # Simplified version of their "DAG_DFTC" algorithm.
  #-------------------------------------------------------------------------------
  # 
  def compute_TC_table(startnode,children,descendants,visited): # recursively depth-first traverse the graph.
    visited.add(startnode)
    descendants[startnode] = set([]) # no descendants yet
    if startnode not in children: return # no children case, leaf nodes
    for childnode in children[startnode]: # for all the children of the startnode
      if childnode not in visited:  # if not yet visited (Note: DFS traversal)
        compute_TC_table(childnode,children,descendants,visited) # recursively visit the childnode, set descendants
      for descendant in list(descendants[childnode]): # each descendant of childnode
        descendants[startnode].add(descendant) # mark descendants of startnode
      descendants[startnode].add(childnode) # mark immediate child of startnode
    return
  
  def print_TC_table(descendants, outfile_name):
    fout = open(outfile_name, 'w')
    for startnode in descendants.keys():
      for endnode in list(descendants[startnode]):
        print('%s,%s' % (startnode,endnode), file = fout)
    fout.close()
    return

  def show_timings(t):
    print('NEO4J Graph DB open: %g' % (t['graph_open_end']-t['graph_open_start']))
    print('ISA extraction from NEO4J: %g' % (t['isa_get_end']-t['isa_get_start']))
    print('TC computation: %g' % (t['TC_end']-t['TC_start']))
    print('Output (csv): %g' % (t['output_write_end']-t['output_write_start']))
    print('Total time: %g' % (t['end']-t['start']))

  # TC_from_graph:
  # command line parsing
  opt = optparse.OptionParser()
  opt.add_option('--neopw64', action='store')
  opt.add_option('--neopw', action='store')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==1 and (opts.neopw or opts.neopw64)):
    print('Usage: cmd TC_from_graph <TCfile-out> --neopw <pw>'); sys.exit(1)
  if opts.neopw and opts.neopw64:
    print('Usage: only one of --neopw and --neopw64 may be specified')
    sys.exit(1)
  if opts.neopw64: # snomed_g v1.2, convert neopw64 to neopw
      opts.neopw = str(base64.b64decode(opts.neopw64),'utf-8') if sys.version_info[0]==3 else base64.decodestring(opts.neopw64) # py2
  output_TC_filename = args[0]
  # Extract ISA relationships from graph (active and inactive)
  timings = {}
  timings['start'] = timer()
  timings['graph_open_start'] = timer()
  neo4j = snomed_g_lib_neo4j.Neo4j_Access(opts.neopw)
  timings['graph_open_end'] = timer()
  timings['isa_get_start'] = timer()
  isa_rels = neo4j.lookup_all_isa_rels()
  timings['isa_get_end'] = timer()
  print('Result class: %s' % str(type(isa_rels)))
  print('Returned %d objects' % len(isa_rels))

  # Compute TC table from ISA relationships, output to specified file.
  timings['TC_start'] = timer()
  children, visited, descendants, concept_node = ({}, set(), {}, "138875005") # init
  build_ISA_graph(children, isa_rels) # build 'children' hash
  compute_TC_table(concept_node, children, descendants, visited)
  timings['TC_end'] = timer()
  timings['output_write_start'] = timer()
  print_TC_table(descendants, output_TC_filename)
  timings['output_write_end'] = timer()
  timings['end'] = timer()
  show_timings(timings)

  # All done
  return
# END TC_from_graph

#---------------------------------------------------------------------------------|
#                             TC_fordate_from_graph                               |
#---------------------------------------------------------------------------------|

def TC_fordate_from_graph(arglist):

  def active_at_date(datestring, isa_edge):
    active = '0' # if no information applies (possible), default to inactive
    # check the current definition, may be in effect at given date
    if isa_edge['effectiveTime'] <= datestring: # the current def in effect
      active = isa_edge['active']
    elif len(isa_edge['history']) > 2: # check history, current definition doesnt apply
      # eg: datestring = 20050101 and current effectiveTime is 20160101 ==> not in effect
      #     hist item 20030101 and 20040101 exists ==> 200401010 in effect in 20050101.
      # note: no need to check current element again, already determined not in effect
      # JSON example [{"typeId": "116680003", "sourceId": "900000000000441003", ...},{...}]
      ordered_history_list = json.loads(isa_edge['history'])
      for hist_elem in ordered_history_list: # list of maps
        if hist_elem['effectiveTime'] > datestring: break # in future vs given date
        if 'active' in hist_elem: active = hist_elem['active']
    return active=='1'
  
  #-------------------------------------------------------------------------------
  # build_ISA_graph(children,filename)
  # Concept: Reads ISA edges from relationships file, stores in the children hash
  #-------------------------------------------------------------------------------
  def build_ISA_graph(children,isa_rels,yyyymmdd):
    for idvalue in isa_rels.keys():
      isa_map = isa_rels[idvalue]
      sourceId, destinationId = isa_map['sourceId'], isa_map['destinationId']
      if active_at_date(yyyymmdd, isa_map):
        if destinationId not in children:            # parent discovered
          children[destinationId] = set([sourceId])  # 1st child, create list
        else:
          children[destinationId].add(sourceId)      # nth child, add to set
    return # done
  
  #-------------------------------------------------------------------------------
  # compute_TC_table(startnode,children,descendants,visited)
  #-------------------------------------------------------------------------------
  # Based on a method described in "Transitive Closure Algorithms
  # Based on Graph Traversal" by Yannis Ioannidis, Raghu Ramakrishnan, and Linda Winger,
  # ACM Transactions on Database Systems, Vol. 18, No. 3, September 1993,
  # Pages: 512 - 576.
  # Simplified version of their "DAG_DFTC" algorithm.
  #-------------------------------------------------------------------------------
  # 
  def compute_TC_table(startnode,children,descendants,visited): # recursively depth-first traverse the graph.
    visited.add(startnode)
    descendants[startnode] = set([]) # no descendants yet
    if startnode not in children: return # no children case, leaf nodes
    for childnode in children[startnode]: # for all the children of the startnode
      if childnode not in visited:  # if not yet visited (Note: DFS traversal)
        compute_TC_table(childnode,children,descendants,visited) # recursively visit the childnode, set descendants
      for descendant in list(descendants[childnode]): # each descendant of childnode
        descendants[startnode].add(descendant) # mark descendants of startnode
      descendants[startnode].add(childnode) # mark immediate child of startnode
    return
  
  def print_TC_table(descendants, outfile_name):
    fout = open(outfile_name, 'w')
    for startnode in descendants.keys():
      for endnode in list(descendants[startnode]):
        print('%s,%s' % (startnode,endnode), file = fout)
    fout.close()
    return

  def show_timings(t):
    print('NEO4J Graph DB open: %g' % (t['graph_open_end']-t['graph_open_start']))
    print('ISA extraction from NEO4J: %g' % (t['isa_get_end']-t['isa_get_start']))
    print('TC computation: %g' % (t['TC_end']-t['TC_start']))
    print('Output (csv): %g' % (t['output_write_end']-t['output_write_start']))
    print('Total time: %g' % (t['end']-t['start']))

  # TC_fordate_from_graph:
  # command line parsing
  opt = optparse.OptionParser()
  opt.add_option('--neopw64', action='store')
  opt.add_option('--neopw', action='store')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==2 and (opts.neopw or opts.neopw64)):
    print('Usage: cmd TC_fordate_from_graph YYYYMMDD <TCfile-out> --neopw <pw>'); sys.exit(1)
  if opts.neopw and opts.neopw64:
    print('Usage: only one of --neopw and --neopw64 may be specified')
    sys.exit(1)
  if opts.neopw64: # snomed_g v1.2, convert neopw64 to neopw
      opts.neopw = str(base64.b64decode(opts.neopw64),'utf-8') if sys.version_info[0]==3 else base64.decodestring(opts.neopw64) # py2
  yyyymmdd, output_TC_filename = args[0], args[1]
  # Extract ISA relationships from graph (active and inactive)
  timings = {}
  timings['start'] = timer()
  timings['graph_open_start'] = timer()
  neo4j = snomed_g_lib_neo4j.Neo4j_Access(base64.decodestring(opts.neopw64))
  timings['graph_open_end'] = timer()
  timings['isa_get_start'] = timer()
  isa_rels = neo4j.lookup_all_isa_rels()
  timings['isa_get_end'] = timer()
  print('Result class: %s' % str(type(isa_rels)))
  print('Returned %d objects' % len(isa_rels))

  # Compute TC table from ISA relationships, output to specified file.
  timings['TC_start'] = timer()
  children, visited, descendants, concept_node = ({}, set(), {}, "138875005") # init
  build_ISA_graph(children, isa_rels, yyyymmdd) # build 'children' hash
  compute_TC_table(concept_node, children, descendants, visited)
  timings['TC_end'] = timer()
  timings['output_write_start'] = timer()
  print_TC_table(descendants, output_TC_filename)
  timings['output_write_end'] = timer()
  timings['end'] = timer()
  show_timings(timings)
  return
# END TC_fordate_from_graph

#---------------------------------------------------------------------------------|
#                             compare_TC_files                                    |
#---------------------------------------------------------------------------------|

def compare_TC_files(arglist):
  # Syntax: cmd <file1> <file2>
  # Concept: see if files have same content, if order of lines dont matter

  def build_hash(f):
    h = {}
    for line in [x.rstrip('\n').rstrip('\r') for x in f]:
      p,c = line.split(',') # parent, child
      if p not in h: h[p] = [c]
      else:          h[p].append(c)
    return h
  
  def compare_hashes(h1,h2):
    # same number of keys?
    k1, k2 = h1.keys(), h2.keys()
    if len(k1) != len(k2):
      print('Key counts differ.  %d vs %d' % (len(k1),len(k2))); return
    # same keys?
    if sorted(k1)!=sorted(k2):
      print('Set of keys do not match'); return
    # same hash values for each key?
    relcount = 0
    for key in k1:
      if sorted(h1[key]) != sorted(h2[key]):
        print('Key hash values do not match')
        print('Case: key=[%s]' % key)
        print('file1: %s' % str(sorted(h1[key])))
        print('file2: %s' % str(sorted(h2[key])))
        return
      else:
        relcount += len(h1[key])
    # hashes match
    print('Contents match (%d parents, %d relationships).' % (len(k1),relcount))
    return

  def verbose_compare_hashes(h1,h2):

    def show_diffs_in_keys(diffs,display_message):
      if len(diffs)>0:
        print((display_message+': %d') % len(diffs))
        for idx,x in enumerate(diffs): print('%4d. [%s]' % (idx+1,x))
        print()

    def show_diffs_for_single_key(key,set1,set2):
      def show_diffs_for_key(diffs,display_message):
        print((display_message+': %d') % len(diffs))
        for idx,x in enumerate(diffs): print('  %4d. [%s]' % (idx+1,x))
        print()
      print('TC sets differ for %s, (NOTE: codes in common: %d)' % (key, len(s1&s2)))
      show_diffs_for_key(list(set1-set2),'  Codes in TC in file1 but not in file2')
      show_diffs_for_key(list(set2-set1),'  Codes in TC in file2 but not in file1')

    # Show difference in key sets
    k1, k2 = set(h1.keys()), set(h2.keys())
    differences_in_keysets = False
    if len(k1) != len(k2): print('Key counts differ.  %d vs %d' % (len(k1),len(k2)))
    if k1!=k2: # if key sets differ
      differences_in_keysets = True
      print('Set of keys do not match')
      show_diffs_in_keys(list(k1-k2),'Keys in file1 that are not in file2')
      show_diffs_in_keys(list(k2-k1),'Keys in file2 that are not in file1')

    # Show differences where keys exist in both
    shared_keys = k1 & k2
    relcount = 0
    diffcount = 0
    for key in list(shared_keys):
      s1 = set(h1[key])
      s2 = set(h2[key]) if key in h2 else set()
      if s1 != s2:
        diffcount += 1
        show_diffs_for_single_key(key, s1, s2)

    # hashes match?
    if not differences_in_keysets and diffcount==0:
      print('Contents match (%d parents, %d relationships).' % (len(k1),relcount))
    else:
      print('Transitive closures to NOT match in file1 and file2')
      if differences_in_keysets: print('Key sets do not match, as reported above.')
      if diffcount>0: print('%d codes with differences' % diffcount)
    return

    
  #compare_TC_files:
  opt = optparse.OptionParser()
  opt.add_option('--verbose',action='store_true',dest='verbose')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==2):
    print('Usage: cmd compare_TC_files <TCfile1> <TCfile2>'); sys.exit(1)
  h = []
  h1 = build_hash(open(args[0]))
  h2 = build_hash(open(args[1]))
  if opts.verbose:
    verbose_compare_hashes(h1,h2)
  else:
    compare_hashes(h1,h2) # 
  return
# END compare_TC_files

#----------------------------------------------------------------------------|
#                                MAIN                                        |
#----------------------------------------------------------------------------|

def parse_and_interpret(arglist):
  command_interpreters = [('TC_from_RF2',TC_from_RF2),
                          ('TC_from_graph',TC_from_graph),
                          ('TC_fordate_from_graph',TC_fordate_from_graph),
                          ('compare_TC_files',compare_TC_files)]
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