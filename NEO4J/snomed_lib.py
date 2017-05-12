#!/usr/bin/python
from __future__ import print_function
import os, shutil, csv, heapq, sys, json
import snomedct_constants

# ----------------------------------------------------------------------------------------
# Module: snomed_lib.py
# Concept: common subroutines for processing SNOMED CT RF2 release files,
#          and various processing algorithms definitions like transitive-closure.
# Author:  Jay Pedersen, University of Nebraska, Mar 26, 2015
# Last Update: June 13, 2016 -- support relationship config item which can state
#              'StatedRelationship' versus the default 'Relationship'.
# Common usage:
#     import snomed_lib
# -----------------------------------------------------------------------------------------
# History:
# -----------------------------------------------------------------------------------------
# Version 1.1 Jay Pedersen, Oct 27, 2015.  Add Transitive_Closure_for_Snapshot class.
# Version 1.0 Jay Pedersen, Mar 26, 2014.  Initial implementation,
#             Speciation event from snomed_g_build_lib, support FULL release as well.

# ------------------------------------------------------------------------------------
#  Global variables defined after call to snomed_g_build_lib.define_config_variables
#
#  snomed_lib.X, where X is one of the set:
#      os_pathsep
#      release_format    <== "Snapshot" (default) or "Full"
#      release_date_str
#      release_center_str
#      snomedct_terminology_dir
#      snomedct_refset_dir
#      relationship_config <== "StatedRelationship" for stated relationships import
#      relationships_filename - full path to Relationshipr or StatedRelationship file
#      output_dir
#      config_file_suffix
#      concept_module_ids
# ------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Hierarchy heads for 19 hierarchies in SNOMED CT
# 419891008 : "Record artifact (record artifact)"
# 370115009 : "Special concept (special concept)"
# 308916002 : "Environment or geographical location (environment / location)"
# 404684003 : "Clinical finding (finding)"
#  48176007 : "Social context (social concept)"
# 362981000 : "Qualifier value (qualifier value)"
# 243796009 : "Situation with explicit context (situation)"
# 123037004 : "Body structure (body structure)"
#  71388002 : "Procedure (procedure)"
#  78621006 : "Physical force (physical force)"
# 373873005 : "Pharmaceutical / biologic product (product)"
# 105590001 : "Substance (substance)"
# 410607006 : "Organism (organism)"
# 254291000 : "Staging and scales (staging scale)"
# 123038009 : "Specimen (specimen)"
# 363787002 : "Observable entity (observable entity)"
# 260787004 : "Physical object (physical object)"
# 272379006 : "Event (event)"
# 900000000000441003 : "SNOMED CT Model Component (metadata)"
# -----------------------------------------------------------------------------

# ------------------------------------------------------------------------------------
#                     Common Routines
# ------------------------------------------------------------------------------------

def clean_dirname(dir): # cleanup directory name from configuration file
  result = dir
  if dir[-1] != os_pathsep:
    print("Note: dirname config -- trailing / added to %s" % dir)
    result += os_pathsep
  return result

def clean_str(s):  #  result can be processed from a CSV file as a string
  return '"'+s.strip().replace('"',r'\"')+'"'

def history_str(changes):
  return clean_str('' if len(changes) <= 1 else json.dumps(changes))

def qsplit(str,delim,strip_text=True): # split which observes double-quotes or single-quotes
    result = []
    s = ''
    in_quoted_area, next_is_escaped = False, False
    single_quote, double_quote, backslash, quote_char = "'", '"', '\\', None
    for idx,c in enumerate(str):
        if not in_quoted_area and c==delim:
            result.append(s.strip() if strip_text else s)
            s = ''
        else: # all other cases, append c
            s += c
            if next_is_escaped: # order matters for \\, and \" and \'
                next_is_escaped = False
            elif c==backslash:
                next_is_escaped = True
            elif not in_quoted_area and (c==single_quote or c==double_quote):
                in_quoted_area = True
                quote_char = c
            elif in_quoted_area and c==quote_char:
                in_quoted_area = False
                quote_char = None
    result.append(s) # trailing data, no sep
    return result

def define_config_variables(config): # create global variables, from config file hash
  # define globals variables (global to this module, accessed snomed_g_build_lib.X)
  global os_pathsep, require_active, release_date_str, release_center_str, release_format
  global snomedct_terminology_dir, snomedct_refset_dir
  global output_dir, relationships_filename, relationship_config
  global config_file_suffix, concept_module_ids, snomed_root_concept_id
  global concept_module_ids_only
  # Set variables
  os_pathsep = config.get('os_pathsep', '/') # JGP 2015/10/07, no default previously
  # NOTE: os_pathsep name is poor?, os.pathsep in python on some linux systems is ':'
  release_format = config.get('release_format', 'Full') # JGP 2015/10/07, was 'Snapshot'
  # NOTE: the 'Snapshot' default made sense for the pre-Historical DB which did not have history
  #       the DB is based on having Historical SNOMED CT content, requiring the Full release
  require_active = config.get('require_active', False if release_format=='Full' else True)
  release_date_str = config['release_date']
  release_center_str = config.get('release_center','INT')
  snomedct_terminology_dir =  clean_dirname(config['terminology_dir'])
  snomedct_refset_dir = clean_dirname(config['refset_dir'])
  relationship_config = config.get('relationship','Relationship') # might be 'StatedRelationship
  if relationship_config not in ['Relationship','StatedRelationship']:
    print('*** Invalid relationship configuration value, only Relationship or StatedRelationship allowed ***')
    sys.exit(1)
  output_dir = clean_dirname(config['output_dir'])
  config_file_suffix = '%s_%s' % (release_center_str, release_date_str)
  concept_module_ids = [900000000000207008,900000000000012004]
  if 'concept_module_ids' in config:
    concept_module_ids += config['concept_module_ids']
    concept_module_ids_only = config['concept_module_ids']
  else:
    concept_module_ids_only = []
  # Note: Can have 'Relationship' (default) or 'StatedRelationship' as RF2 file name defining the relationships
  #       to import.  Set the 'relationship' configuration value to 'StatedRelationship' to change the default.
  relationships_filename = snomedct_terminology_dir+"sct2_%s_%s_%s.txt" % (relationship_config,release_format,config_file_suffix)
  snomed_root_concept_id = 138875005
  return

def rf2_file_path(element):  # NOTE: case-sensitve, 'concept' is ok, 'Concept' is not
  global snomedct_terminology_dir, relationship_config,release_format, config_file_suffix
  if element=='relationship' or element=='Relationship' or element=='StatedRelationship':
    # relationship_config can be 'StatedRelationship' or 'Relationship'"
    if element=='relationship':
      path = snomedct_terminology_dir+"sct2_%s_%s_%s.txt" % (relationship_config,release_format,config_file_suffix)
    else:
      path = snomedct_terminology_dir+"sct2_%s_%s_%s.txt" % (element,release_format,config_file_suffix)
  elif element=='concept':
    path = snomedct_terminology_dir+"sct2_%s_%s_%s.txt" % ('Concept',release_format,config_file_suffix)
  elif element=='description':
    path = snomedct_terminology_dir+"sct2_%s_%s-en_%s.txt" % ('Description',release_format,config_file_suffix)
  elif element=='language':
    path = snomedct_refset_dir+"der2_cRefset_Language%s-en_%s.txt" % (release_format,config_file_suffix)
  else:
    raise ValueError('element:%s to snomed_lib.rf2_file_path' % element)
  return path
def role_name(s): # convert FSN for defining concept role into displayable name, eg: FINDING_SITE
  return s.replace(' (attribute)','').replace(' ','_').replace('"','').replace('-','').replace('(','').replace(')','').replace('___','_').upper()

def make_hash(fields, values): # convert fields from header line in CSV into hash (name to column number)
  return { fieldname : values[idx] for idx, fieldname in enumerate(fields) }

def make_fields_hash(fields):
  return { fieldname : idx for idx, fieldname in enumerate(fields) }

def make_csv_header_line(h,sep=','): # hash is { 'id': 0, 'name':1, ... }
  rev = { v : k for k,v in h.items() } # reverse hash, keyed by value
  fieldnames = [ rev[idx] for idx in xrange(len(h.keys())) ]
  return sep.join(fieldnames)

def make_csv_data_line(fields,sep=','): # order is order defined in csv header line
  return sep.join(fields)

# ----------------------------------------------------------------------------------
# Routine: snomed_sort
# Concept: sort tab-separated text file, based on specified keys
#          Default sort requirements -- sort by id, then effectiveTime.
#          If the file is small enough, sort it memory and write the result.
#          If files are large, split the file into smaller "chunks" (files),
#          sort those chunks, and then merge them into the final result.
# Parameters:
#          fn: filename of CSV file
#          out_fn: filename for output sorted file.
#          colnames -- column names (from header) to sort by, 
#          integer_keys -- sort columns are all integers (typical -- id, effectiveDate)
# Limitations:
#          No sorting by a mix of integer and string fields, as of the current
#          implementation (all keys must be string, or all nteger, as of the moment).
# ------------------------------------------------------------------------------------

def snomed_sort(fn, out_fn, delim='\t', colnames=['id','effectiveTime'],integer_keys=True):

    def sort_rows_and_write_file(rows, out_fn, delim, sort_columns, integer_keys, header=None):
        """ Input: rows, sorting instructions, output file name, delimiter
            Output: sorted rows written to output file, using delimiter, NO HEADER line
            Note: output is not quoted and snomed release files are not quoted
        """
        if integer_keys:
            rows.sort(key=lambda row: get_integer_sort_key(row, sort_columns))
        else:
            rows.sort(key=lambda row: get_sort_key(row, sort_columns))
        print('creating %s, header: %s' % (out_fn,('True' if header else 'False')))
        with open(out_fn, 'w') as outf:
            if header: outf.write(delim.join(header)+'\n')
            for row in rows: outf.write(delim.join(row)+'\n')
        return

    def create_sorted_chunks(reader, sort_columns, max_bytes, delim, dir, integer_keys):
        """ Make sorted files of size max_bytes, which we can mergesort
        """
        chunk_files = []
        chunk = 1; chunk_bytes = 0; rows = []
        for row in reader:
            rows.append(row)
            chunk_bytes += sys.getsizeof(row)
            if chunk_bytes >= max_bytes: # create next chunk file
                # sort rows and write to chunk file
                filename = os.path.join(dir, 'chunk%d.csv' % chunk)
                sort_rows_and_write_file(rows, filename, delim, sort_columns, integer_keys) # no header
                chunk_files.append(filename)
                # prep for next file
                chunk += 1; chunk_bytes = 0; rows = []
        # deal with any trailing data
        if len(rows) > 0:
            filename = os.path.join(dir, 'chunk%d.csv' % chunk)
            sort_rows_and_write_file(rows, filename, delim, sort_columns, integer_keys) # no header
            chunk_files.append(filename)
        # return list of created files (for merge-sorting)
        return chunk_files

    def get_sort_key(row, sort_columns): # sort method support, multiple column sorting
        return [row[sort_column] for sort_column in sort_columns]

    def get_integer_sort_key(row, sort_columns): # sort method support, multiple column sorting
        return [int(row[sort_column]) for sort_column in sort_columns]

    # Merge sorted files support (heapq is the key, minheap)
    def decorated_file(f, key): # decorator support for heapq.merge
        for row in f: yield (key(row), row)

    def opentsv(filename): # open tab-separated file as csv
        return csv.reader(open(filename), delimiter='\t')

    def mergeFiles(infiles, outfile, keyfunc, delim, header):
        tsvfiles = map(opentsv, infiles) # open files ==> list of csv.reader(s)
        print('Merging files, creating %s' % outfile)
        outf = open(outfile, 'w')
        outf.write(delim.join(header)+'\n') # want header in output file
        for line in heapq.merge(*[decorated_file(f, keyfunc) for f in tsvfiles]):
            outf.write(delim.join(line[1])+'\n') # line[1] is next row
        outf.close()

    # snomed_sort
    max_MBs = 128 # 2^7, hardcoded concept of "too large for memory sort"
    max_bytes = max_MBs*1024*1024

    # determine file size, see if small enough to sort in mem
    filestat = os.stat(fn)
    filesize = filestat.st_size

    reader = csv.reader(open(fn), delimiter=delim)
    header = reader.next() # snomed release files always have header

    sort_columns = [ header.index(colname) for colname in colnames ]
    # IDEA: trailing "-" on column name to sort descending ==>
    # ISSUE: making generic key routine for sort that can support this
    #         for any type of data

    # Case 1: small file
    if filesize <= max_bytes: # small enough to sort in memory?
        rows = [row for row in reader] # remaining rows after header
        sort_rows_and_write_file(rows, out_fn, delim, sort_columns, integer_keys, header)
        return # DONE

    # Case 2: large file ==> split, sort and merge
    global output_dir
    SORT_DIR = output_dir+'snomed_sort_%d' % os.getpid()
    if not os.path.exists(SORT_DIR): os.mkdir(SORT_DIR)

    # split input file into smaller temp files, sort them
    sorted_chunk_files = \
        create_sorted_chunks(reader, sort_columns, max_bytes, delim, SORT_DIR, integer_keys)

    # mergesort the sorted chunks to create the output file
    if integer_keys:
        mergeFiles(sorted_chunk_files, out_fn, lambda row: get_integer_sort_key(row, sort_columns), delim, header)
    else:
        mergeFiles(sorted_chunk_files, out_fn, lambda row: get_sort_key(row, sort_columns), delim, header)

    # delete the temporary files and directory
    print('Deleting temporary files and folder : %s' % SORT_DIR)
    shutil.rmtree(SORT_DIR)
    return

# ------------------------------------------------------------------------------------
# class: Transitive_Closure_for_Snapshot
# concept: Compute the Transitive Closure for a SNOMED CT release,
#          given a Description file in Snapshot format
# interface: 
#   constructor(relationship_filename)
#   print_TC_table(filename) -- create CSV file with <concept>,<subsumed-concept> lines.
#   TC_for_concept(concept) -- returns set of "subsumed" concepts for this concept,
#                              not including the concept itself
# ------------------------------------------------------------------------------------

class Transitive_Closure_for_Snapshot:

  def __init__(self, relationship_fn):  # SNAPSHOT relationship assumed? y?
    self.in_isa, self.ancestors = {}, {} # init
    snomedct_root_concept_node, visited = 138875005, set()
    self.build_incoming_ISA_hash(relationship_fn) # build children hash
    self.compute_TC_table(snomedct_root_concept_node, visited)
    self.out_isa = {} # optional, only set if build_outgoing_ISA_hash called
    self.out_DR = {} # optional, only set if build_outgoing_DR_hash called
    return

  #-------------------------------------------------------------------------------
  # build_incoming_ISA_hash(children,filename)
  # Concept: Reads ISA edges from relationships file, stores in the children hash
  #-------------------------------------------------------------------------------
  def build_incoming_ISA_hash(self, relationship_fn):
    for idx,line in enumerate(x.rstrip('\n').rstrip('\r') for x in open(relationship_fn)):
      # line -- [0]id,[1]effectiveTime,[2]active,[3]moduleId,[4]sourceId,[5]destinationId,
      #         [6]relationshipGroup,[7]typeId,[8]characteristicTypeId,[9]modifierId
      if idx==0: continue # ignore HEADER
      values = line.split('\t')
      active, sourceId, destinationId, typeId = \
                           (int(values[2]), int(values[4]), int(values[5]), int(values[7]))
      if typeId==116680003 and active==1:        # active ISA relationship
        if destinationId not in self.in_isa:            # incoming ISA to destinationId
          self.in_isa[destinationId] = set([sourceId])  # 1st child, create list
        else:
          self.in_isa[destinationId].add(sourceId)      # nth child, add to set
    return

  # Optional - not needed directly by TC, but useful for general ISA processing
  def build_outgoing_ISA_hash(self, relationship_fn):
    self.out_isa = {}
    for idx,line in enumerate(x.rstrip('\n').rstrip('\r') for x in open(relationship_fn)):
      # line -- [0]id,[1]effectiveTime,[2]active,[3]moduleId,[4]sourceId,[5]destinationId,
      #         [6]relationshipGroup,[7]typeId,[8]characteristicTypeId,[9]modifierId
      if idx==0: continue # ignore HEADER
      values = line.split('\t')
      active, sourceId, destinationId, typeId = \
                                  (int(values[2]), int(values[4]), int(values[5]), int(values[7]))
      if typeId==116680003 and active==1:        # active ISA relationship
        if sourceId not in self.out_isa:         # parent discovered (outgoing ISA destination)
          self.out_isa[sourceId] = set([destinationId])  # 1st child, create list
        else:
          self.out_isa[sourceId].add(destinationId)      # nth child, add to set
    return

  # Optional - not needed directly by TC, but useful for general ISA processing
  def build_outgoing_DR_hash(self, relationship_fn):
    self.out_DR = {}
    for idx,line in enumerate(x.rstrip('\n').rstrip('\r') for x in open(relationship_fn)):
      # line -- [0]id,[1]effectiveTime,[2]active,[3]moduleId,[4]sourceId,[5]destinationId,
      #         [6]relationshipGroup,[7]typeId,[8]characteristicTypeId,[9]modifierId
      if idx==0: continue # ignore HEADER
      values = line.split('\t')
      active, sourceId, destinationId, rolegroup, typeId = \
                                  (int(values[2]), int(values[4]), int(values[5]), int(values[6]), int(values[7]))
      if typeId!=116680003 and active==1:        # active defining relationship (not ISA)
        if sourceId not in self.out_DR:         # create key as needed
          self.out_DR[sourceId] = {}
        if rolegroup not in self.out_DR[sourceId]:
          self.out_DR[sourceId][rolegroup] = []  # create rolegroup as needed
        av_pair = [typeId, destinationId]
        self.out_DR[sourceId][rolegroup].append(av_pair)
    return

  #-------------------------------------------------------------------------------
  # compute_TC_table(startnode,visited)
  #-------------------------------------------------------------------------------
  # Based on "Transitive Closure Algorithms Based on Graph Traversal"
  # by Yannis Ioannidis, Raghu Ramakrishnan, and Linda Winger,
  # ACM Transactions on Database Systems, Vol. 18, No. 3, September 1993,
  # Pages: 512 - 576.
  # Simplified version of their "DAG_DFTC" algorithm.
  # NOTES: recursive definition,
  #        visited -- a set, must be initialized to set() before calling.
  #-------------------------------------------------------------------------------
  def compute_TC_table(self, startnode, visited): # recursively depth-first traverse the graph.
    visited.add(startnode)
    self.ancestors[startnode] = set([]) # no ancestors yet
    if startnode not in self.in_isa: return # no parent case, leaf nodes
    for parentnode in self.in_isa[startnode]: # for all the parents of the startnode
      if parentnode not in visited:  # if not yet visited (Note: DFS traversal)
        self.compute_TC_table(parentnode,visited) # recursively visit the parentnode, set ancestors
      for ancestor in list(self.ancestors[parentnode]): # each ancestor of parentnode
        self.ancestors[startnode].add(ancestor) # mark ancestors of startnode
      self.ancestors[startnode].add(parentnode) # mark immediate parent of startnode
    return

  def TC_for_concept(self, sctid):
    return self.ancestors[sctid]

  def incoming_ISA_concepts(self,concept):
    if concept not in self.in_isa: return set()
    return self.in_isa[concept]

  def outgoing_ISA_concepts(self,concept):
    if concept not in self.out_isa: return set()
    return self.out_isa[concept]
    
  def defining_rels_for_concept(self,concept):
    # Result valid only if build_outgoing_DR_hash already called
    result = []
    if concept in self.out_DR:
      for rolegroup in self.out_DR[concept].keys():
        result.append(self.out_DR[concept][rolegroup])
    return result # eg: [[[1,2],[3,4]],[[5,6]]]  -- 2 role groups

  def print_TC_table(self, outfile_name):
    fout = open(outfile_name, 'w')
    for startnode in self.ancestors.keys():
      for endnode in list(self.ancestors[startnode]):
        print('%s,%s' % (startnode,endnode), file = fout)
    fout.close()
    return

# ------------------------------------------------------------------------------------
# class: Snomedct_Code_Types_for_Snapshot
# concept: create sets which indicate the set of codes and which are
#          fully defined and which are primitive.
# Note:  codes are integer values
# interface: 
#   X = constructor(concept_snapshot_filename)
#   X.all_concepts
#   X.primitive_concepts -- set
#   X.fully_defined_concepts -- set
# ------------------------------------------------------------------------------------

class Snomedct_Code_Types_for_Snapshot:
  def __init__(self, concept_fn):
    # Process concepts -- determine fully-defined vs primitive
    self.all_concepts, self.primitive_concepts, self.fully_defined_concepts = set(), set(), set()
    field_names, fields_d = None, None
    for idx,line in enumerate([x.rstrip('\n').rstrip('\r') for x in open(concept_fn)]):
      if idx==0: # HEADER
        field_names = line.split('\t')
        fields_d = { b: a for a, b in enumerate(field_names) }
      else: # DATA
        fields = line.split('\t')
        if fields[ fields_d['active'] ]=='0': continue # ignore non-active
        sctid = int(fields[ fields_d['id'] ])
        self.all_concepts.add(sctid)
        if int(fields[ fields_d['definitionStatusId'] ])==900000000000074008: # PRIMITIVE
          self.primitive_concepts.add(sctid)
        else:
          self.fully_defined_concepts.add(sctid)
    return # done processing file

# ------------------------------------------------------------------------------------
# class: Snomedct_FSNs_for_Snapshot
# concept: create sets which indicate the set of codes and which are
#          fully defined and which are primitive.
# Note:  codes are integer values
# interface: 
#   X = constructor(description_snapshot_filename)
#   X.FSN[code]
# ------------------------------------------------------------------------------------

class Snomedct_FSNs_for_Snapshot:
  def __init__(self, description_fn):
    self.FSN = {}
    field_names, fields_d = None, None
    for idx,line in enumerate([x.rstrip('\n').rstrip('\r') for x in open(description_fn)]):
      if idx==0: # Header line - defines attribute names
        field_names = line.split('\t')
        fields_d = { b: a for a, b in enumerate(field_names) }
      else:
        fields = line.split('\t')
        if fields[ fields_d['active'] ]=='0': continue # ignore non-active
        if int(fields[ fields_d['typeId'] ]) == 900000000000003001: # FSN
          self.FSN[ int(fields[ fields_d['conceptId'] ]) ] = fields[ fields_d['term'] ]
    f.close()

# ------------------------------------------------------------------------------------
# method: compute_proximal_primitives
# concept: Generic processing of any "snapshot" RF2 file (concept, description, etc)
# interface: 
#   concept -- (input) target snomed ct concept code (integer), to find proximal primitives of
#   TC -- (input, pre-computed) transitive closure object,
#          instance of snomed_lib.Transitive_Closure_for_Snapshot class.
#   visited -- (modified) initialized to set([]), for use by graph processing
#   s -- output proximal primitives, pre-initialized to set()
#   primitives -- (input,pre-computed) snomed ct codes (integers) that are primitives
# Example usage:
#   TC = snomed_lib.Transitive_Closure_for_Snapshot(relationships_fn)
#   TC.build_outgoing_ISA_hash(relationships_fn) # outgoing ISA edges determination
#   Code_Types = snomed_lib.Snomedct_Code_Types_for_Snapshot(concept_fn)
#   primitives = Code_types.primitive_concepts
#   visited = set([138875005]) # ignore SNOMEDCT root concept
#   pp_set = set()
#   snomed_lib.compute_proximal_primitives(<concept>, TC, visited, primitives, pp_set)
#   print("Proximal primitives are %s" % str(pp_set))
# ------------------------------------------------------------------------------------

def compute_proximal_primitives(concept, TC, visited, primitives, s):
  # Output: s -- set of proximal primitives
  # See interface discussion above for additional details on parameters

  # Step 1 -- find candidates (recursive), embedded function
  def pp_find_candidates(concept, TC, visited, s, primitives):
    if concept in visited: return # already visited
    visited.add(concept)
    if concept in primitives:
      s.add(concept)
    else: # fully-defined
      isa_set = TC.outgoing_ISA_concepts(concept)
      for target in isa_set: # targets of direct outgoing ISAs
        if target in visited or target in s:
          pass # ignore
        elif target in primitives:
          s.add(target) # primitive, add to set, dont visit
        else: # not primitive, not visited, not in s
          pp_find_candidates(target, TC, visited, s, primitives)
    return

  # Step 1.  Compute candidates (handles case where concept is primitive)
  pp_find_candidates(concept, TC, visited, s, primitives)

  # Step 2.  Prune the set.
  # One or more elements of candidate set s may be subsumed by others in the set.
  # These subsuming elements must be removed.
  # If there is an ISA path towards the root from some X to some Y which are both
  # in the set then Y must be removed from the set.
  slist = list(s) # list of candidate elements
  for y in slist:
    set_subsumed_by_y = TC.TC_for_concept(y) # note: will not include y
    xset = set_subsumed_by_y.intersection(s)
    if len(xset) > 0: s.remove(y)
  return

# ------------------------------------------------------------------------------------
# Class: Process_Rf2_Release_File
# Concept: Generic processing of Delta/Snapshot RF2 file (concept, description, etc),
# Purpose: Replace the Process_Snapshot_Format_File, which is not specific to
#          to Snapshot files.
# Interface: 
#   constructor(filename)
#   process_file(callback,filter) -- call the callback for each record passing the given filter
#   process_records(callback,filter,require_active) -- callback with filtering and "active"
# ------------------------------------------------------------------------------------
class Process_Rf2_Release_File: # Delta or Snapshot or Full

  def __init__(self, filename):
    self.filename = filename
    self.f = open(self.filename)
    # read header line ==> determine field name to field index mapping and vice-versa
    header = self.f.readline().rstrip('\n').rstrip('\r') # deal with windows,linux line-separators
    self.field_names = header.split('\t') # field number to field name
    self.fields_d = { fieldname : idx for idx, fieldname in enumerate(self.field_names) } # name to idx
    self.field_count = len(self.field_names)
    self.line_number = 1

  def get_fields_from_line(self, line):
    return line.rstrip('\n').rstrip('\r').split('\t')

  def process_file(self, callback_rtn, filter_callback_rtn, require_active=True):
    id_idx = self.fields_d['id'] # every file has an 'id' attribute
    while True:
      line = self.f.readline()
      if not line: break # EOF
      self.line_number += 1
      fields = self.get_fields_from_line(line)
      if filter_callback_rtn == None or filter_callback_rtn(fields, self.fields_d, require_active): # record we care about?
        callback_rtn(fields, self.fields_d, []) # history is 3rd arg
    self.f.close() # EOF
    return

  def process_records(self, callback_rtn, filter_callback_rtn, require_active=True):
    # same as process_file for snapshot file, not true for full view (multi records combined, history)
    id_idx = self.fields_d['id'] # every file has an 'id' attribute
    while True:
      line = self.f.readline()
      if not line: break
      self.line_number += 1
      fields = self.get_fields_from_line(line)
      if filter_callback_rtn==None or filter_callback_rtn(fields, self.fields_d, require_active): # record we care about?
        callback_rtn(fields, self.fields_d, []) # history is 3rd arg
    self.f.close() # EOF
    return

  def return_to_BOF(self):
    try:    self.f.seek(0) # back to beginning of file, can re-read
    except: self.f = open(self.filename) # file already closed
    return

# ------------------------------------------------------------------------------------
# class: Process_Snapshot_Format_File
# concept: Generic processing of any "snapshot" RF2 file (concept, description, etc)
# interface: 
#   constructor(filename)
#   process_file(callback,filter) -- call the callback for each record passing the given filter
# ------------------------------------------------------------------------------------

class Process_Snapshot_Format_File:

  def __init__(self, filename):
    self.filename = filename
    self.f = open(self.filename)
    # read header line ==> determine field name to field index mapping and vice-versa
    header = self.f.readline().rstrip('\n').rstrip('\r') # deal with windows,linux line-separators
    self.field_names = header.split('\t') # field number to field name
    self.fields_d = { fieldname : idx for idx, fieldname in enumerate(self.field_names) } # name to idx
    self.field_count = len(self.field_names)
    self.line_number = 1

  def get_fields_from_line(self, line):
    return line.rstrip('\n').rstrip('\r').split('\t')

  def process_file(self, callback_rtn, filter_callback_rtn, require_active=True):
    id_idx = self.fields_d['id'] # every file has an 'id' attribute
    while True:
      line = self.f.readline()
      if not line: break
      self.line_number += 1
      fields = self.get_fields_from_line(line)
      if filter_callback_rtn==None or filter_callback_rtn(fields, self.fields_d, require_active): # record we care about?
        callback_rtn(fields, self.fields_d, []) # history is 3rd arg
    self.f.close() # EOF
    return

  def process_records(self, callback_rtn, filter_callback_rtn, require_active=True):
    # same as process_file for snapshot file, not true for full view (multi records combined, history)
    id_idx = self.fields_d['id'] # every file has an 'id' attribute
    while True:
      line = self.f.readline()
      if not line: break
      self.line_number += 1
      fields = self.get_fields_from_line(line)
      if filter_callback_rtn==None or filter_callback_rtn(fields, self.fields_d, require_active): # record we care about?
        callback_rtn(fields, self.fields_d, []) # history is 3rd arg
    self.f.close() # EOF
    return

def process_snap_concept_file(callback_rtn, require_active=True, sorted=False):
  global output_dir, config_file_suffix, release_format

  def filter_callback_rtn(fields, fields_d, require_active):
    global concept_module_ids
    modid  = int(fields[ fields_d['moduleId'] ])
    active = int(fields[ fields_d['active'] ])
    return (not require_active or active==1) and (modid in concept_module_ids)

  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = dir + "sct2_Concept_%s_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn, require_active)
  return

def process_snap_description_file(callback_rtn, target=None, require_active=True, sorted=False):
  # target is None (all records) or FSN (fully-specified names)
  global config_file_suffix, release_format

  def filter_callback_rtn(fields, fields_d, require_active=True):
    global concept_module_ids
    active = int(fields[ fields_d['active'] ])
    modid  = int(fields[ fields_d['moduleId'] ])
    typeId = int(fields[ fields_d['typeId'] ])
    if target==None:    result = modid in concept_module_ids
    elif target=='FSN': result = modid in concept_module_ids and typeId==900000000000003001 # FSN
    else:               raise ValueError('Invalid target in process_snap_description_file <<%s>>' % str(target))
    return (not require_active or active==1) and (result)

  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = dir + "sct2_Description_%s-en_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn, require_active)
  return

def process_snap_relationship_file(callback_rtn, target=None, require_active=True, sorted=False):
  # target is None (all records), 'ISA' or 'DR' (defining relationships)
  global relationships_filename
  global relationship_config, config_file_suffix, release_format

  def filter_callback_relationship(fields, fields_d, target):
    typeId   = int(fields[ fields_d['typeId'] ])
    if target==None:    result = True # ISA and DR
    elif target=='DR':  result = typeId!=116680003 # NOT ISA ==> Defining rel
    elif target=='ISA': result = typeId==116680003 # ISA
    else:               raise ValueError('Invalid target in process_snap_relationship_file <<%s>>' % str(target))
    return result

  def filter_callback_rtn(fields, fields_d, require_active=True): # call common filter, specifying local target
    active = int(fields[ fields_d['active'] ]) # NOTE: target from outer routine param
    return (not require_active or active==1) and filter_callback_relationship(fields, fields_d, target) # see note above

  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = relationships_filename # dir + "sct2_%s_%s_%s.txt" % (relationship_config, release_format,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn, require_active)
  return

def process_snap_relationship_records(callback_rtn, target=None, require_active=True, sorted=False):
  # target is None (all records), 'ISA' or 'DR' (defining relationships)
  global config_file_suffix, release_format

  def filter_callback_relationship(fields, fields_d, target):
    typeId   = int(fields[ fields_d['typeId'] ])
    if target==None:    result = True # ISA and DR
    elif target=='DR':  result = typeId!=116680003 # NOT ISA ==> Defining rel
    elif target=='ISA': result = typeId==116680003 # ISA
    else:               raise ValueError('Invalid target in process_snap_relationship_file <<%s>>' % str(target))
    return result

  def filter_callback_rtn(fields, fields_d, require_active=True): # call common filter, specifying local target
    active = int(fields[ fields_d['active'] ]) # NOTE: target from outer routine param
    return (not require_active or active==1) and filter_callback_relationship(fields, fields_d, target) # see note above

  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = relationships_filename # dir + "sct2_%s_%s_%s.txt" % (relationship_config, release_format,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_records(callback_rtn, filter_callback_rtn)
  return

def process_snap_language_file(callback_rtn, require_active=True, sorted=False):
  global relationships_filename
  global relationship_config, config_file_suffix, release_format

  def filter_callback_rtn(fields, fields_d, require_active=True):
    global concept_module_ids
    active = int(fields[ fields_d['active'] ])
    modid  = int(fields[ fields_d['moduleId'] ])
    refsetId = int(fields[ fields_d['refsetId'] ])
    return (not require_active or active==1) and (modid in concept_module_ids and refsetId==900000000000509007)# US

  dir = output_dir if sorted else snomedct_refset_dir # sorted file in output_dir
  fn = dir + "der2_cRefset_Language%s-en_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn, require_active)
  return

# ------------------------------------------------------------------------------------
# Routine: process_concept_file()
# Input:   snomed concept file -- sct2_Concept_Snapshot
# Concept: call callback when for each active concept passing module-id checks
# Note:    generic, the callback routine has no default -- must be supplied
# Note: if used with "Full" file, will returns every line separately
# ------------------------------------------------------------------------------------

def process_concept_file(callback_rtn, require_active=True):

  def filter_callback_rtn(fields, fields_d):
    global concept_module_ids, require_active
    modid  = int(fields[ fields_d['moduleId'] ])
    active = int(fields[ fields_d['active'] ])
    return (not require_active or active==1) and modid in concept_module_ids # TODO: check require_active usage

  fn = snomedct_terminology_dir+"sct2_Concept_%s_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

# ------------------------------------------------------------------------------------
# Routine: process_description_file()
# Input:   snomed description file -- sct2_Description_Snapshot
# Concept: callback when an active description passing module-id checks is encountered
# ------------------------------------------------------------------------------------

def process_description_file(callback_rtn, target=None, require_active=True):

  def filter_callback_rtn(fields, fields_d):
    global concept_module_ids
    # fields are [id,effectiveTime,active,moduleId,conceptId,languageCode,typeId,term,caseSignificanceId]
    modid  = int(fields[ fields_d['moduleId'] ])
    active = int(fields[ fields_d['active'] ])
    typeId = int(fields[ fields_d['typeId'] ])
    result = False
    if (not require_active or active==1) and modid in concept_module_ids:
      if target=='FSN': result = typeId==900000000000003001 # FSN
      else:             result = True
    return result

  # Note: what of clean_str on "term"?
  fn = snomedct_terminology_dir+"sct2_Description_%s-en_%s.txt" % (release,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

# ------------------------------------------------------------------------------------
# Routine: process_relationship_file_DRs/ISA()
# Input:   snomed relationships file -- sct2_[Stated]Relationship_Snapshot
# Concept: callback when an active relationship passing module-id checks is encountered
# ------------------------------------------------------------------------------------

def process_relationship_file_DRs(callback_rtn, release="Snapshot", require_active=True):
  fn = relationships_filename # snomedct_terminology_dir+"sct2_%s_%s_%s.txt" % (relationship_config,release,config_file_suffix)
  f = open(fn, 'r')
  firstline = True
  while True:
    line = f.readline()
    if not line: break
    fields = line.rstrip('\n').rstrip('\r').split('\t')
    # [id,effectiveTime,active,moduleId,sourceId,destinationId,relationshipGroup,typeId,
    #  characteristicTypeId,modifierId]
    if firstline:  # header
      rkeys = make_fields_hash(fields)
      firstline = False
    else: # data line, filter out non-active terms or wrong module ids
      active   = int(fields[ rkeys['active'] ])
      typeId   = int(fields[ rkeys['typeId'] ])
      if (not require_active or active==1) and typeId!=116680003:  # NOT ISA ==> defining rel
        callback_rtn(typeId, fields, rkeys)
  f.close()
  return

def process_relationship_file_ISA(callback_rtn, release="Snapshot", require_active=True):
  fn = relationships_filename # snomedct_terminology_dir+"sct2_%s_%s_%s.txt" % (relationship_config,release,config_file_suffix)
  f = open(fn, 'r')
  firstline = True
  while True:
    line = f.readline()
    if not line: break
    fields = line.rstrip('\n').rstrip('\r').split('\t')
    # [id,effectiveTime,active,moduleId,sourceId,destinationId,relationshipGroup,typeId,
    #  characteristicTypeId,modifierId]
    if firstline:  # header
      rkeys = make_fields_hash(fields)
      firstline = False
    else: # data line, filter out non-active terms or wrong module ids
      active   = int(fields[ rkeys['active'] ])
      typeId   = int(fields[ rkeys['typeId'] ])
      if (not require_active or active==1) and typeId==116680003:  # ISA
        callback_rtn(fields, rkeys)
  f.close()
  return

# ------------------------------------------------------------------------------------
# Routine: process_language_file()
# Input:   snomed language file -- der2_cRefset_LanguageSnapshot
# Concept: callback when an active description passing module-id checks is encountered
# ------------------------------------------------------------------------------------

def process_language_file(callback_rtn, release="Snapshot", require_active=True):
  global concept_module_ids
  fn = snomedct_refset_dir+"der2_cRefset_Language%s-en_%s.txt" % (release,config_file_suffix)
  f = open(fn, 'r')
  firstline = True
  while True:
    line = f.readline()
    if not line: break
    fields = line.rstrip('\n').rstrip('\r').split('\t')
    # [id[0], effectiveTime[1], active[2], moduleId[3], refsetId[4],
    #  referencedComponentId[5], acceptabilityId[6] ]
    if firstline:  # header
      lkeys = make_fields_hash(fields)
      firstline = False
    else: # data line, filter out non-active terms or wrong module ids
      active   = int(fields[ lkeys['active'] ])
      modid    = int(fields[ lkeys['moduleId'] ])
      refsetId = int(fields[ lkeys['refsetId'] ])
      if (not require_active or active==1) and modid in concept_module_ids and refsetId==900000000000509007: # US
        callback_rtn(fields, lkeys)
  f.close()
  return

# ------------------------------------------------------------------------
#  Standard Callbacks -- to build FSNhash from descriptions , etc
# ------------------------------------------------------------------------

# Callback for description file processor ==> add to FSN hash
def description_callback(sctid, term, fields, fieldname_hash):
  global FSNhash  # Note: snomed_lib.FSNhash for users of the module
  FSNhash[sctid] = term
  return

# callback for concept file processor ==> add active concept
def concept_callback(sctid, fields, fieldname_hash):
  global snomed_concept_ids # Note: snomed_lib.snomed_concept_ids for users
  snomed_concept_ids.add(sctid)
  return

# Class -- Process_Full_Format_File -- combine multi records for same concept
#
# Process FULL-format Concept text file with header describing fields, and
# "id" as first attribute.  There can be multiple records for any concept,
# one for the initial record and one for each update to the record.  These
# are stored contiguously in the FULL-format file.
#
# Only call the callback routine when all ontiguous records for a particular
# concept have all been processed.  The callback routine is passed the attributes
# from the last record for the concept, but is also passed the history of changes
# via the 'changes' array (1 dictionary for each changes, first is the initial).
#
# Note: #1. require_active is not applicable, as we process ALL records for each concept,
#           so it is not a parameter.
#       #2. release is not required, as we known we are processing a FULL release format file.

class Process_Full_Format_File:

  def __init__(self, filename):
    self.filename = filename
    self.f = open(self.filename)
    # read header line ==> determine field name to field index mapping and vice-versa
    header = self.f.readline().rstrip('\n').rstrip('\r')
    self.line_number = 1
    self.field_names = header.split('\t') # field number to field name
    self.fields_d = { fieldname : idx for idx, fieldname in enumerate(self.field_names) } # name to idx
    self.field_count = len(self.field_names)
    self.changes = []

  def track_changes(self, fields, prev_fields):
    change_d = {} # build dictionary with changes, append to 'changes' key
    for idx in range(self.field_count):
      if fields[idx] != prev_fields[idx]:
        change_d[self.field_names[idx]] = fields[idx]
    self.changes.append(change_d)
    return

  def get_fields_from_line(self, line):
    return line.rstrip('\n').rstrip('\r').split('\t')

  def process_file(self, callback_rtn, filter_callback_rtn):
    id_idx = self.fields_d['id'] # every file has an 'id' attribute
    prev_fields = self.get_fields_from_line( self.f.readline() ) # 1st record
    self.changes = [ { a:b for a,b in zip(self.field_names, prev_fields) } ] # initial state
    self.line_number += 1
    while True:
      line = self.f.readline()
      if not line: break
      self.line_number += 1
      fields = self.get_fields_from_line(line)
      if fields[id_idx] == prev_fields[id_idx]:
        self.track_changes(fields, prev_fields) # same id as last time, track changes
      else: # id changed, prev_fields was the last record for that sctid
        if filter_callback_rtn(prev_fields, self.fields_d): # is cached record one we care about?
          callback_rtn(prev_fields, self.fields_d, self.changes) # prev_fields is most-recent record for id
        self.changes = [ { a:b for a,b in zip(self.field_names, fields) } ] # initial state
      prev_fields = fields[:] # save field values for change comparison
    # EOF
    self.f.close()
    # always cached data -- prev_fields and self.changes
    if filter_callback_rtn(prev_fields, self.fields_d): # cached record is one we care about?
      callback_rtn(prev_fields, self.fields_d, self.changes)
    return

  def process_records(self, callback_rtn, filter_callback_rtn):
    id_idx = self.fields_d['id'] # every file has an 'id' attribute
    while True:
      line = self.f.readline()
      if not line: break
      self.line_number += 1
      fields = self.get_fields_from_line(line)
      if filter_callback_rtn(fields, self.fields_d): # record we care about?
        callback_rtn(fields, self.fields_d, self.line_number)
    # EOF
    self.f.close()
    return

def process_full_concept_file(callback_rtn, sorted=True):
  global output_dir, config_file_suffix, release_format

  def filter_callback_rtn(fields, fields_d):
    global concept_module_ids
    modid  = int(fields[ fields_d['moduleId'] ])
    return (modid in concept_module_ids)

  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = dir + "sct2_Concept_%s_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Full_Format_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

def process_full_concept_records(callback_rtn, sorted=True):
  global config_file_suffix, release_format

  def filter_callback_rtn(fields, fields_d):
    global concept_module_ids
    modid  = int(fields[ fields_d['moduleId'] ])
    return (modid in concept_module_ids)

  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = dir + "sct2_Concept_%s_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Full_Format_File(fn)
  file_reader.process_records(callback_rtn, filter_callback_rtn)
  return

def process_full_description_file(callback_rtn, target=None, sorted=True):
  # target is None (all records) or FSN (fully-specified names)
  global config_file_suffix, release_format

  def filter_callback_rtn(fields, fields_d):
    global concept_module_ids
    modid  = int(fields[ fields_d['moduleId'] ])
    typeId = int(fields[ fields_d['typeId'] ])
    if target==None:    result = modid in concept_module_ids
    elif target=='FSN': result = modid in concept_module_ids and typeId==900000000000003001 # FSN
    else:               raise ValueError('Invalid target in process_full_description_file <<%s>>' % str(target))
    return result

  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = dir + "sct2_Description_%s-en_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Full_Format_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

def filter_callback_relationship(fields, fields_d, target):
  typeId   = int(fields[ fields_d['typeId'] ])
  if target==None:    result = True # target from process_full_relationship context
  elif target=='DR':  result = typeId!=116680003 # NOT ISA ==> Defining rel
  elif target=='ISA': result = typeId==116680003 # ISA
  else:               raise ValueError('Invalid target in process_full_relationship_file <<%s>>' % str(target))
  return result

def process_full_relationship_file(callback_rtn, target=None, sorted=True):
  # target is None (all records), 'ISA' or 'DR' (defining relationships)
  global config_file_suffix, release_format, relationships_filename

  def filter_callback_rtn(fields, fields_d): # call common filter, specifying local target
    return filter_callback_relationship(fields, fields_d, target)
  
  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = relationships_filename # dir + "sct2_%s_%s_%s.txt" % (relationship_config, release_format,config_file_suffix)
  file_reader = Process_Full_Format_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

def process_full_relationship_records(callback_rtn, target=None, sorted=True):
  # target is None (all records), 'ISA' or 'DR' (defining relationships)
  global relationships_filename
  global relationship_config, config_file_suffix, release_format

  def filter_callback_rtn(fields, fields_d): # call common filter, specifying local target
    return filter_callback_relationship(fields, fields_d, target)
  
  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = relationships_filename # dir + "sct2_%s_%s_%s.txt" % (relationship_config,release_format,config_file_suffix)
  file_reader = Process_Full_Format_File(fn)
  file_reader.process_records(callback_rtn, filter_callback_rtn)
  return

def process_full_language_file(callback_rtn, sorted=True):
  global config_file_suffix, release_format

  def filter_callback_rtn(fields, fields_d):
    global concept_module_ids
    modid  = int(fields[ fields_d['moduleId'] ])
    refsetId = int(fields[ fields_d['refsetId'] ])
    return (modid in concept_module_ids  and refsetId==900000000000509007 )# US

  dir = output_dir if sorted else snomedct_refset_dir # sorted file in output_dir
  fn = dir + "der2_cRefset_Language%s-en_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Full_Format_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

# Note: NO MAIN, library module
