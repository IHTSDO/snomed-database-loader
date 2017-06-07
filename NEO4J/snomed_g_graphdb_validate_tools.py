#!/usr/bin/python
from __future__ import print_function
import csv, optparse, datetime, json, sys, re, os, base64, errno, io
import snomed_g_lib_rf2, snomed_g_lib_neo4j, snomedct_constants

'''
Module:  snomed_g_validate_graphdb_tools.py
Author:  Jay Pedersen, July 2016
Purpose: Implement commands which support validating a SNOMED_G database.
Syntax and Semantics:
          python <pgm> validate_graphdb --element concept --release_type delta/snapshot/full --rf2 <location> --newpw64 <pw>
Example:
          python snomed_g_validate_graphdb_tools.py \
             validate --element concept --release_type full --neopw64 <ps> \
                 --rf2 /cygdrive/c/sno/snomedct/SnomedCT_RF2Release_US1000124_20160301
'''

def db_data_prep(v):
  return v if isinstance(v,unicode) else unicode( (str(v) if isinstance(v, int) else v) , "utf8")

def clean_str(s):  #  result can be processed from a CSV file as a string
  return '"'+s.strip().replace('"',r'\"')+'"' # embedded double-quote processing

def csv_clean_str(s):
  return '"'+s.strip().replace('"','""').replace('\\','\\\\')+'"' # embedded double-quote processing

# TIMING functions
def timing_start(timing_d, nm): timing_d[nm] = { 'start': datetime.datetime.now() }
def timing_end(timing_d, nm):   timing_d[nm]['end'] = datetime.datetime.now()
def show_timings(timestamps):
  for key in sorted(timestamps.keys()):
    delta = timestamps[key]['end'] - timestamps[key]['start']
    print('%-35s : %s' % (key, str(delta)))

#--------------------------------------------------------------------------------
#             validate_graphdb --element concept --rf2 <dir> --release_type delta       |
#--------------------------------------------------------------------------------

def validate_graphdb(arglist):

  def rf2_filename(element, view=None): # rf2_folders is set in validate_graphdb initialization
    return rf2_folders.rf2_file_path(element, view) # eg: 'concept'

  def old_compute_hist_changes(new_field_values, prev_field_values, field_names): # find map with only modified fields
    return { field_names[idx] : new_field_values[idx] for idx in range(len(field_names)) if db_data_prep(new_field_values[idx]) != db_data_prep(prev_field_values[idx]) }

  '''
  HISTORY COMPUTATION -- Example information for a concept:
  
  Information state example (need to understand for history computation)
    csv_fields  = ['id','effectiveTime','active','moduleId','definitionStatusId','FSN','history']
    field_names = ['id','effectiveTime','active','moduleId','definitionStatusId']
    renamed_fields = {}
    id -- '293672009'
    concepts_d[id]['20160301'] -- concepts_d[id] is a map keyed by effectiveTime,
                                  its value ==> list of attribute values for that time,
                                  in same order as in RF2 file
    graph_matches_d[id] (graph) --
              {u'nodetype': u'concept', u'effectiveTime': u'20060131', u'FSN': u'Antiemetic allergy (disorder)',
               u'definitionStatusId': u'900000000000073002', u'sctid': u'293672009', u'active': u'1',
               u'moduleId': u'900000000000207008', u'id': u'293672009',
               u'history': u'[{"active": "1", "effectiveTime": "20020131", ...}, ...]'}
  '''

  def compute_history_string(id, rf2_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields):
    if opts.release_type == 'full': # compute history, have all information
      historical_effectiveTimes = sorted(rf2_d[id].keys())[:-1] # excluce 'current' (latest)
      hist = [ { nm: rf2_d[id][effTime][rf2_fields_d[renamed_fields.get(nm,nm)]] for nm in field_names } for effTime in historical_effectiveTimes ] \
             if len(rf2_d[id].keys()) > 1 else []
    else: # not FULL, can be missing historical info
      if id not in graph_matches_d:
        hist = []
      else:
        old_history =  graph_matches_d[id]['history'] # JSON string or empty string
        old_field_values = [ graph_matches_d[id][nm] for nm in field_names ]
        if len(old_history) == 0: # no prev history, old values ==> previous history)
          hist = [ { a:b for a,b in zip(field_names, old_field_values) } ]
        else: # existing history, not FULL release, append previous values from graph (previous history)
          hist = json.loads(old_history) + [ ( { a:b for a,b in zip(field_names, old_field_values) } ) ]
    return json.dumps(hist) if len(hist) > 0 else ''

  def build_csv_output_line(id, non_rf2_fields, current_effTime, rf2_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_fields):
    csv_data = [None]*len(csv_fields_d.keys())
    for nm in field_names: csv_data[csv_fields_d[nm]] = db_data_prep(rf2_d[id][current_effTime][rf2_fields_d[renamed_fields.get(nm,nm)]])
    for k,v in non_rf2_fields: csv_data[csv_fields_d[k]] = db_data_prep(v) # eg: [('history','<hist-json-str>'),...]
    if None in csv_data: raise InvalidValue('csv_data %s' % str(csv_data))
    for nm in quoted_fields: csv_data[csv_fields_d[nm]] = csv_clean_str(csv_data[csv_fields_d[nm]]) # quote only necessary fields
    return db_data_prep( ','.join(csv_data) ) # output_line

  #------------------------------------------------------------------------------|
  #        CONCEPT CSV files creation -- concept_new.csv, concept_chg.csv        |
  #------------------------------------------------------------------------------|

  def validate_concepts():

    def concept_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in concepts_d: concepts_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise InvalidValue('*** Concept id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in concepts_d[id]: raise InvalidValue('*** Concept id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      concepts_d[id][effTime] = fields[:] # attributes in RF2-defined order

    def Fsn_cb(fields, fields_d, hist):
      all_Fsn_in_Rf2_d[ db_data_prep(fields[ fields_d['conceptId'] ]) ] = db_data_prep(fields[ fields_d['term'] ]) # FSN

    def Fsn_filter(fields, fields_d, hist):
      return fields[ fields_d['typeId'] ] == snomedct_constants.SNOMEDCT_TYPEID_FSN

    # validate_concepts:
    # ==> generate concept_new.csv, concept_chg.csv -- from info in RF2 and NEO4J
    stats = { 'error_count': 0 }
    timing_d = { }
    timing_idx = 0
    timing_overall_nm = '{:04d}_validate_concepts'.format(timing_idx); timing_start(timing_d, timing_overall_nm)
    timing_idx += 1; timing_nm = '{:04d}_read_RF2_description'.format(timing_idx); timing_start(timing_d, timing_nm)
    all_Fsn_in_Rf2_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('description') ).process_file(Fsn_cb, Fsn_filter, False)
    timing_end(timing_d, timing_nm)
    f_new, f_chg = io.open('concept_new.csv','w',encoding='utf8'),io.open('concept_chg.csv','w',encoding='utf8')
    outfile_list = [f_new,f_chg]
    rf2_fields = attributes_by_file.rf2_fields['concept']
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['concept'] # ['id','effectiveTime','active',...,'history']
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['FSN','history'] ] # exclude non-RF2 history and FSN (external)
    renamed_fields = attributes_by_file.renamed_fields['concept'] # dictionary
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['concept']
    csv_header = db_data_prep(','.join(csv_fields)) # "id,effectiveTime,..."
    for f in outfile_list: print(csv_header, file=f) # header
    # create concepts_d with information from DELTA/SNAPSHOT/FULL concept file
    timing_idx += 1; timing_nm = '{:04d}_read_RF2_concept'.format(timing_idx); timing_start(timing_d, timing_nm)
    concepts_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('concept') ).process_file(concept_cb, None, False)
    timing_end(timing_d, timing_nm)
    rf2_idlist = concepts_d.keys()
    Fsn_d = { k: all_Fsn_in_Rf2_d[k] for k in list(set(all_Fsn_in_Rf2_d.keys()).intersection(set(rf2_idlist))) } # sets compare ascii+unicode
    print('count of RF2 ids: %d' % len(rf2_idlist))
    # Look for existing FSN values in graph
    print('count of FSNs in RF2: %d' % len(Fsn_d.keys()))
    if opts.action=='create':
      graph_matches_d = {}
    else:
      # NEO4J -- look for these concepts (N at a time)
      timing_idx += 1; timing_nm = '{:04d}_neo4j_lookup_concepts'.format(timing_idx); timing_start(timing_d, timing_nm)
      if opts.release_type=='delta':
        graph_matches_d = neo4j.lookup_concepts_for_ids(rf2_idlist) # This includes FSN values
      else:
        graph_matches_d = neo4j.lookup_all_concepts()
      timing_end(timing_d, timing_nm)
      print('Found %d of the IDs+FSNs in the graph DB:' % len(graph_matches_d.keys()))
      # Set any missing FSN values from the Graph
      target_id_set = set(graph_matches_d.keys()) - set(Fsn_d.keys())
      print('Filling in %d FSN values from the graph' % len(target_id_set))
      for id in list(target_id_set): Fsn_d[id] = graph_matches_d[id]['FSN']
      print('count of FSNs after merge with RF2 FSNs: %d' % len(Fsn_d.keys()))
    # Make sure all ids have an FSN
    if sorted(Fsn_d.keys()) != sorted(rf2_idlist): raise ValueError('*** (sanity check failure) Cant find FSN for all IDs in release ***')
    # GENERATE CSV FILES
    timing_idx += 1; timing_nm = '{:04d}_generate_csvs'.format(timing_idx); timing_start(timing_d, timing_nm)
    for id in rf2_idlist:
      current_effTime = sorted(concepts_d[id].keys())[-1] # highest effectiveTime is current
      if id not in graph_matches_d:
        stats['new'] += 1
      elif concepts_d[id][current_effTime][rf2_fields_d['effectiveTime']] == graph_matches_d[id]['effectiveTime']:
        stats['no_change'] += 1; continue # NO CHANGE ==> SKIP
      else:
        stats['change'] += 1
      hist_str = compute_history_string(id, concepts_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields)
      output_line = build_csv_output_line(id,[('FSN',Fsn_d[id]),('history',hist_str)],current_effTime, concepts_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      print(output_line,file=(f_new if not id in graph_matches_d else f_chg))
    # Done generating CSVs
    timing_end(timing_d, timing_nm)
    timing_end(timing_d, timing_overall_nm)
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list: f.close() # cleanup
    print('Total RF2 elements: {:d}, ERRORS: {:d}'.format(len(rf2_idlist), stats['error_count']))
    show_timings(timing_d)
    sys.exit(stats['error_count']) # CONVENTION - return number of errors as program code (zero ==> SUCCESS)
  # END validate_concepts

  #------------------------------------------------------------------------------|
  #        DESCRIPTION CSV files  -- descrip_new.csv, descrip_chg.csv            |
  #------------------------------------------------------------------------------|
  def validate_descriptions():

    def description_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in description_d: description_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise InvalidValue('*** Concept id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in description_d[id]: raise InvalidValue('*** Concept id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      description_d[id][effTime] = fields[:] # attributes in RF2-defined order
    def language_cb(fields, fields_d, hist):
      id = fields[ fields_d['referencedComponentId'] ] # DONT USE "id", use the id associated with the Description
      if id in language_d and language_d[id]['refsetId']==snomedct_constants.SNOMEDCT_REFSETID_USA: return # PREFER US definition
      language_d[id] = { nm : fields[ fields_d[nm] ] for nm in fields_d.keys() }
    def snapshot_language_cb(fields, fields_d, hist):
      id = fields[ fields_d['referencedComponentId'] ]
      if id in snapshot_language_d and snapshot_language_d[id]['refsetId']==snomedct_constants.SNOMEDCT_REFSETID_USA: return # prefer US def
      snapshot_language_d[id] = { nm : fields[ fields_d[nm] ] for nm in fields_d.keys() }
    def compute_descriptionType(typeId,acceptabilityId):
      return 'FSN' if typeId=='900000000000003001' \
             else 'Preferred' if typeId=='900000000000013009' and acceptabilityId=='900000000000548007' \
             else 'Synonym'

    # validate_descriptions:
    # ==> generate descrip_new.csv, descrip_chg.csv -- from info in RF2 and NEO4J
    stats = { 'error_count': 0 }
    timing_d = {}
    timing_idx = 0
    timing_overall_nm = '%04d_validate_descriptions' % timing_idx; timing_start(timing_d, timing_overall_nm)
    # READ RF2 DESCRIPTION FILE
    timing_idx += 1; timing_nm = '%04d_read_RF2_description' % timing_idx; timing_start(timing_d, timing_nm)
    description_d, language_d, snapshot_language_d = {}, {}, {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('description') ).process_file(description_cb, None, False)
    timing_end(timing_d, timing_nm)
    rf2_idlist = description_d.keys()
    print('count of RF2 ids: %d' % len(rf2_idlist))
    # READ RF2 LANGUAGE FILE
    timing_idx += 1; timing_nm = '%04d_read_RF2_language' % timing_idx; timing_start(timing_d, timing_nm)
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('language') ).process_file(language_cb, None, False)
    timing_end(timing_d, timing_nm)
    if opts.release_type=='delta': # need snapshot file for fallback of potential missing historical information
      print('read snapshot language values');
      timing_idx += 1; timing_nm = '%04d_read_rf2_language_snapshot' % timing_idx; timing_start(timing_d, timing_nm)
      snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('language','Snapshot') ).process_file(snapshot_language_cb, None, False); print('read')
      timing_end(timing_d, timing_nm)
    # CSV INIT, ATTRIBUTE NAMES MANAGEMENT
    f_new, f_chg = io.open('descrip_new.csv','w',encoding='utf8'),io.open('descrip_chg.csv','w',encoding='utf8')
    outfile_list = [f_new,f_chg]
    rf2_fields = attributes_by_file.rf2_fields['description']
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['description'] # ['id','effectiveTime','active',...,'history']
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['id128bit','acceptabilityId','refsetId','descriptionType','history'] ]
    renamed_fields = attributes_by_file.renamed_fields['description'] # dictionary
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['description']
    csv_header = db_data_prep(','.join(csv_fields)) # "id,effectiveTime,..."
    for f in outfile_list: print(csv_header, file=f) # header
    if opts.action=='create':
      graph_matches_d = {}
    else: # 'update' (compare vs Graph)
      # READ NEO4J DESCRIPTIONS
      timing_idx += 1; timing_nm = '%04d_neo4j_lookup_DESCRIPTIONS' % timing_idx; timing_start(timing_d, timing_nm)
      if opts.release_type=='delta':
        graph_matches_d = neo4j.lookup_descriptions_for_ids(rf2_idlist) # This includes FSN values
      else:
        graph_matches_d = neo4j.lookup_all_descriptions()
      timing_end(timing_d, timing_nm)
      print('count of Descriptions in NEO4J: %d' % len(graph_matches_d.keys()))
      print('count of Language Descriptions in RF2: %d' % len(list(set(language_d.keys()).intersection(set(rf2_idlist)))))
    # GENERATE CSV FILES
    timing_idx += 1; timing_nm = '%04d_generate_csvs' % timing_idx; timing_start(timing_d, timing_nm)
    for id in rf2_idlist:
      current_effTime = sorted(description_d[id].keys())[-1] # highest effectiveTime is current
      if id not in graph_matches_d:
        stats['new'] += 1
      elif description_d[id][current_effTime][rf2_fields_d['effectiveTime']] == graph_matches_d[id]['effectiveTime']:
        stats['no_change'] += 1; continue # NO CHANGE ==> NO ADDITIONAL PROCESSING FOR THIS ENTRY
      else:
        stats['change'] += 1
      hist_str = compute_history_string(id, description_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields)
      # Need to add the following to the description_d definition ==>
      #  'id128bit','acceptabilityId','descriptionType' (compute from acceptabilityId),'refsetId'
      computed = {}
      current_typeId = description_d[id][current_effTime][rf2_fields_d['typeId']]
      if id in language_d:
        computed['id128bit']        = language_d[id]['id']
        computed['acceptabilityId'] = language_d[id]['acceptabilityId']
        computed['refsetId']        = language_d[id]['refsetId']
        computed['descriptionType'] = compute_descriptionType(current_typeId,language_d[id]['acceptabilityId'])
      elif id in snapshot_language_d: # empty unless view=='delta', things not necessarily in Graph (any missing releases in graph)
        computed['id128bit']        = snapshot_language_d[id]['id']
        computed['acceptabilityId'] = snapshot_language_d[id]['acceptabilityId']
        computed['refsetId']        = snapshot_language_d[id]['refsetId']
        computed['descriptionType'] = compute_descriptionType(current_typeId,snapshot_language_d[id]['acceptabilityId'])
      elif id in graph_matches_d:
        computed['id128bit']        = graph_matches_d[id]['id128bit']
        computed['acceptabilityId'] = graph_matches_d[id]['acceptabilityId']
        computed['refsetId']        = graph_matches_d[id]['refsetId']
        computed['descriptionType'] = graph_matches_d[id]['descriptionType']
      else:
        stats['no_language'] += 1
        computed['id128bit']        = '<NA>'
        computed['acceptabilityId'] = '<NA>'
        computed['refsetId']        = '<NA>'
        computed['descriptionType'] = '<NA>'
        if stats['no_language']<=1000: print('*** Missing LANGUAGE records for Description %s ***' % id)
        elif stats['no_language']==1001: print('*** Missing more than 1000 LANGUAGE records ***')
      non_rf2_fields = [(x,computed[x]) for x in ['id128bit','acceptabilityId','refsetId','descriptionType']]+[('history',hist_str)]
      output_line = build_csv_output_line(id, non_rf2_fields, current_effTime, description_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      print(output_line,file=(f_new if not id in graph_matches_d else f_chg))
    # Done generating CSVs
    timing_end(timing_d, timing_nm)
    timing_end(timing_d, timing_overall_nm)
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list: f.close() # cleanup
    if stats['no_language'] > 0: print('Missing %d LANGUAGE records' % stats['no_language'])
    print('Total RF2 elements: {:d}, ERRORS: {:d}'.format(len(rf2_idlist), stats['error_count']))
    show_timings(timing_d)
    # DONE
    for f in outfile_list: f.close() # cleanup
    sys.exit(stats['error_count']) # CONVENTION - return number of errors as program code (zero ==> SUCCESS)
  # END validate_descriptions

  #------------------------------------------------------------------------------|
  #            ISA_REL CSV files  -- isa_rel_new.csv, isa_rel_chg.csv            |
  #------------------------------------------------------------------------------|
  def validate_isa_rels():

    def isa_rel_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in isa_rel_d: isa_rel_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise InvalidValue('*** ISA id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in isa_rel_d[id]: raise InvalidValue('*** ISA id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      isa_rel_d[id][effTime] = fields[:] # attributes in RF2-defined order
    def isa_rel_filter(fields, fields_d, hist):
      return fields[ fields_d['typeId'] ] == snomedct_constants.SNOMEDCT_TYPEID_ISA

    # validate_isa_rels:
    # ==> generate isa_rel_new.csv, isa_rel_chg.csv -- from info in RF2 and NEO4J
    stats = { 'error_count': 0 }
    timing_d = {}
    timing_idx = 0
    timing_overall_nm = '%04d_make_isa_rels_csvs' % timing_idx; timing_start(timing_d, timing_overall_nm)
    # READ RF2 RELATIONSHIP FILE - EXTRACT ISA
    timing_idx += 1; timing_nm = '%04d_read_RF2_relationship' % timing_idx; timing_start(timing_d, timing_nm)
    isa_rel_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('relationship') ).process_file(isa_rel_cb, isa_rel_filter, False)
    timing_end(timing_d, timing_nm)
    rf2_idlist = isa_rel_d.keys()
    print('count of ids in RF2: %d' % len(rf2_idlist))
    # CSV FILE INIT, ATTRIBUTE NAME MANAGEMENT
    f_new, f_chg = io.open('isa_rel_new.csv','w',encoding='utf8'),io.open('isa_rel_chg.csv','w',encoding='utf8')
    outfile_list = [f_new,f_chg]
    rf2_fields = attributes_by_file.rf2_fields['isa_rel']
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['isa_rel'] # ['id','effectiveTime','active',...,'history']
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['history'] ]
    renamed_fields = attributes_by_file.renamed_fields['isa_rel'] # dictionary
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['isa_rel']
    csv_header = db_data_prep(','.join(csv_fields)) # "id,effectiveTime,..."
    for f in outfile_list: print(csv_header, file=f) # header
    if opts.action=='create':
      graph_matches_d = {}
    else:
      # EXTRACT ISA RELATIONSHIPS FROM NEO4J
      timing_idx += 1; timing_nm = '%04d_get_neo4j_ISA' % timing_idx; timing_start(timing_d, timing_nm)
      all_in_graph = neo4j.lookup_all_isa_rels() # looking for ISA by its 'id' is SLOOOOOOW, get them ALL instead
      timing_end(timing_d, timing_nm)
      print('count of ALL ISA in NEO4J: %d' % len(all_in_graph.keys()))
      graph_matches_d = { x: all_in_graph[x] for x in list(set(all_in_graph.keys()).intersection(set(rf2_idlist))) } # successful compare ascii+unicode, way faster than "if" test
      print('count of ISA in NEO4J: %d' % len(graph_matches_d.keys()))
    # GENERATE CSV FILES FOR NEW AND CHG
    timing_idx += 1; timing_nm = '%04d_csv_generation' % timing_idx; timing_start(timing_d, timing_nm)
    for id in rf2_idlist: # must compute updated history for each
      current_effTime = sorted(isa_rel_d[id].keys())[-1] # highest effectiveTime is current
      if id not in graph_matches_d:
        stats['new'] += 1
      elif isa_rel_d[id][current_effTime][rf2_fields_d['effectiveTime']] == graph_matches_d[id]['effectiveTime']:
        stats['no_change'] += 1; continue # NO CHANGE ==> NO ADDITIONAL PROCESSING FOR THIS ENTRY
      else:
        stats['change'] += 1
      hist_str = compute_history_string(id, isa_rel_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields)
      output_line = build_csv_output_line(id,[('history',hist_str)],current_effTime, isa_rel_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      print(output_line,file=(f_new if not id in graph_matches_d else f_chg))
    # Done generating CSVs
    timing_end(timing_d, timing_nm)
    timing_end(timing_d, timing_overall_nm)
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list: f.close() # cleanup
    print('Total RF2 elements: {:d}, ERRORS: {:d}'.format(len(rf2_idlist), stats['error_count']))
    show_timings(timing_d)
    sys.exit(stats['error_count']) # CONVENTION - return number of errors as program code (zero ==> SUCCESS)
  # END validate_isa_rels

  #------------------------------------------------------------------------------|
  #    DEFINING_REL CSV files  -- defining_rel_new.csv, defining_rel_chg.csv     |
  #------------------------------------------------------------------------------|
  def validate_defining_rels():

    def defining_rel_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in defining_rel_d: defining_rel_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise InvalidValue('*** DEFINING-REL id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in defining_rel_d[id]: raise InvalidValue('*** DEFINING-REL id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      defining_rel_d[id][effTime] = fields[:] # attributes in RF2-defined order
    def defining_rel_filter(fields, fields_d, hist):
      return fields[ fields_d['typeId'] ] != snomedct_constants.SNOMEDCT_TYPEID_ISA

    # validate_defining_rels:
    # ==> generate defining_rel_new.csv, defining_rel_chg.csv -- from info in RF2 and NEO4J
    stats = { 'error_count': 0 }
    timing_d = {}
    timing_idx = 0
    timing_overall_nm = '%04d_make_defining_rels_csvs' % timing_idx; timing_start(timing_d, timing_overall_nm)
    # READ all_roles.csv (tiny file)
    timing_idx += 1; timing_nm = '%04d_read_all_roles' % timing_idx; timing_start(timing_d, timing_nm)
    roleHash = {}
    with open('all_roles.csv') as f:
      for idx,line in enumerate(x.rstrip('\n').rstrip('\r') for x in f):
        if idx==0: continue # typeId,rolename
        typeId, rolename = line.split(',')
        roleHash[typeId] = rolename
    timing_end(timing_d, timing_nm)
    # READ RF2 RELATIONSHIP FILE - EXTRACT DEFINING-RELS
    timing_idx += 1; timing_nm = '%04d_read_RF2_relationship' % timing_idx; timing_start(timing_d, timing_nm)
    defining_rel_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('relationship') ).process_file(defining_rel_cb, defining_rel_filter, False)
    timing_end(timing_d, timing_nm)
    rf2_idlist = defining_rel_d.keys()
    print('count of ids in RF2: %d' % len(rf2_idlist))
    # CSV FILE INIT, ATTRIBUTE NAME MANAGEMENT
    f_new, f_chg = io.open('defining_rel_new.csv','w',encoding='utf8'),io.open('defining_rel_chg.csv','w',encoding='utf8')
    f_edge_rem = io.open('defining_rel_edge_rem.csv','w',encoding='utf8')
    print(db_data_prep('id,rolegroup,sourceId,destinationId'),file=f_edge_rem)
    outfile_list = [f_new,f_chg]
    f_DRs = {} # per-defining-relationship type
    rf2_fields = attributes_by_file.rf2_fields['defining_rel']
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['defining_rel'] # ['id','effectiveTime','active',...,'history']
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['history'] ]
    renamed_fields = attributes_by_file.renamed_fields['defining_rel'] # dictionary
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['defining_rel']
    csv_header = db_data_prep(','.join(csv_fields)) # "id,effectiveTime,..."
    for f in outfile_list: print(csv_header, file=f) # header
    if opts.action == 'create':
      graph_matches_d = {}
    else:
      # EXTRACT DEFINING RELATIONSHIPS FROM NEO4J
      timing_idx += 1; timing_nm = '%04d_get_neo4j_DEFINING_RELS' % timing_idx; timing_start(timing_d, timing_nm)
      all_in_graph = neo4j.lookup_all_defining_rels() # looking for rel by its 'id' is SLOOOOOOW, get them ALL instead
      timing_end(timing_d, timing_nm)
      print('count of ALL DEFINING-REL in NEO4J: %d' % len(all_in_graph.keys()))
      graph_matches_d = { x: all_in_graph[x] for x in list(set(all_in_graph.keys()).intersection(set(rf2_idlist))) } # successful compare ascii+unicode, way faster than "if" test
      print('count of DEFINING-REL in NEO4J: %d' % len(graph_matches_d.keys()))
    # GENERATE CSV FILES FOR NEW AND CHG
    timing_idx += 1; timing_nm = '%04d_csv_generation' % timing_idx; timing_start(timing_d, timing_nm)
    f_used_roles = open('used_roles.csv','w'); print('typeId,rolename',file=f_used_roles)
    for id in rf2_idlist: # must compute updated history for each
      current_effTime = sorted(defining_rel_d[id].keys())[-1] # highest effectiveTime is current
      current_typeId = defining_rel_d[id][current_effTime][rf2_fields_d['typeId']]
      rolegroup_changed = False # if this occurred, treat as create instead of change (as it requires edge remove+edge create)
      if id not in graph_matches_d:
        stats['new'] += 1
        if current_typeId not in f_DRs:
          f_DRs[current_typeId] = open('DR_%s_new.csv' % roleHash[current_typeId],'w'); print(csv_header, file=f_DRs[current_typeId])
          print('%s,%s' % (current_typeId, roleHash[current_typeId]), file=f_used_roles)
      elif defining_rel_d[id][current_effTime][rf2_fields_d['effectiveTime']] == graph_matches_d[id]['effectiveTime']:
        stats['no_change'] += 1; continue # NO CHANGE ==> NO ADDITIONAL PROCESSING FOR THIS ENTRY
      else:
        stats['change'] += 1
        # see if rolegroup changed
        if graph_matches_d[id]['rolegroup'] != defining_rel_d[id][current_effTime][ rf2_fields_d['relationshipGroup'] ]: # rolegroup change?
          print('%s,%s,%s,%s' % (id,graph_matches_d[id]['rolegroup'],graph_matches_d[id]['sctid'],graph_matches_d[id]['destinationId']),file=f_edge_rem)
          rolegroup_changed = True # treat this as an edge create case
      hist_str = compute_history_string(id, defining_rel_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields)
      output_line = build_csv_output_line(id,[('history',hist_str)],current_effTime, defining_rel_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      for f in ([f_chg] if rolegroup_changed==False and id in graph_matches_d else [f_new, f_DRs[current_typeId]]): print(output_line,file=f)
    # Done generating CSVs
    timing_end(timing_d, timing_nm)
    timing_end(timing_d, timing_overall_nm)
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list+[f_edge_rem]+[f_DRs[typeId] for typeId in f_DRs.keys()]+[f_used_roles]: f.close() # cleanup
    print('Total RF2 elements: {:d}, ERRORS: {:d}'.format(len(rf2_idlist), stats['error_count']))
    show_timings(timing_d)
    sys.exit(stats['error_count']) # CONVENTION - return number of errors as program code (zero ==> SUCCESS)
  # END validate_defining_rels

  # validate_graphdb:
  # Output: result displayed to STDOUT, exceptions)
  opt = optparse.OptionParser()
  opt.add_option('--verbose',action='store_true',dest='verbose')
  opt.add_option('--rf2',action='store',dest='rf2')
  opt.add_option('--element',action='store', choices=['concept','description','isa_rel','defining_rel'])
  opt.add_option('--release_type', action='store', dest='release_type', choices=['delta','snapshot','full'])
  opt.add_option('--exceptions_file', action='store', dest='exceptions_file')
  opt.add_option('--neopw64', action='store', dest='neopw64')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==0 and opts.rf2 and opts.element and opts.release_type and opts.neopw64):
    print('Usage: validate_graphdb --element concept/description/isa_rel/defining_rel --rf2 <dir> --release_type delta/snapshot [--verbose] --neopw64 <base64pw>')
    sys.exit(1)
  # Connect to NEO4J
  #neopw = base64.decodestring( json.loads(open('necares_config.json').read())['salt'] )
  neo4j = snomed_g_lib_neo4j.Neo4j_Access(base64.decodestring(opts.neopw64))
  # Connect to RF2 files
  rf2_folders = snomed_g_lib_rf2.Rf2_Folders(opts.rf2, opts.release_type)
  # Information for comparing RF2 to Graph
  attributes_by_file = snomed_g_lib_rf2.Rf2_Attributes_per_File()
  # TODO - open exception file (append if it exists, write header if it did not exist)
  fn = opts.exceptions_file
  exceptions_file = open(fn, 'a')
  if exceptions_file.tell()==0: print('element,id,description',file=exceptions_file) # header
  # determine the fields names, NOTE: history is assumed as added last field
  if   opts.element=='concept':      validate_concepts()
  elif opts.element=='description':  validate_descriptions()
  elif opts.element=='isa_rel':      validate_isa_rels()
  elif opts.element=='defining_rel': validate_defining_rels()
  else:
    print('unknown element [%s]' % opts.element); sys.exit(1)
  return
# END validate_graphdb

#--------------------------------------------------------------------------------------|
#                       Support classes for validate_graphdb                           |
#--------------------------------------------------------------------------------------|
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
          end TEXT, \
          error_count INTEGER
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

  def add_record(self, seq, step, command, result, status, seconds, output, error, start, end, error_coutn):
      db = sqlite3.connect(self.dbfilename)
      c = db.cursor()
      # insert into build table
      c.execute('INSERT INTO build(seq, step, command, result, status, seconds, output, error, start, end, error_count) \
                  VALUES(?,?,?,?,?,?,?,?,?,?)', (seq, step, command, result, status, seconds, output, error, str(start), str(end), error_count))
      db.commit()
      c.close()
      db.close() # keep db closed most of the time

class save_and_report_results():
  def set_step_variables(self, stepname):
    self.result_s = self.results_d[stepname].get('result','<NA>')
    self.status = self.results_d[stepname].get('status',-100)
    self.expected_status = self.results_d[stepname].get('expected_status',0)
    self.seconds = self.results_d[stepname].get('elapsed_seconds',-1)
    self.output = self.results_d[stepname].get('STDOUT','').decode('utf-8')
    self.error = self.results_d[stepname].get('STDERR','').decode('utf-8')
    self.cmd_start_s = str(self.results_d[stepname].get('cmd_start','<NI>'))
    self.cmd_end_s = str(self.results_d[stepname].get('cmd_end','<NI>'))
    self.command = self.results_d[stepname].get('command','<NI>')
    self.error_count = self.results_d[stepname].get('error_count',0) # TODO: is this a reasonable default?

  def __init__(self, DB, seqnum, stepnames, results_d):
    self.DB = DB # StatusDb object (sqlite3 database)
    self.seqnum = seqnum # Backup sequence number, first backup ever is #1, second #2, etc
    self.results_d = results_d
    self.stepnames = [x for x in stepnames if x in self.results_d]
    self.procedure_worked = all(self.results_d[stepname]['result'] == 'SUCCESS' for stepname in self.stepnames)
    self.failed_steps = [x for x in self.stepnames if self.results_d[x]['result'] != 'SUCCESS']
    # Get to work -- Write result to DB, see if everything worked
    for stepname in self.stepnames:
      self.set_step_variables(stepname)
      # Write the status to the database
      self.DB.add_record(self.seqnum, stepname, self.command, self.result_s, self.status, self.seconds, self.output, self.error,
                self.cmd_start_s, self.cmd_end_s, self.error_count)
    # SUMMARY display
    print()
    print('RESULT: %s' % 'SUCCESS' if self.procedure_worked else 'FAILED (steps: %s)' % str(self.failed_steps))
    print()
    print('SUMMARY:')
    print()
    for stepname in self.stepnames:
      self.set_step_variables(stepname)
      print('%-25s : %-25s, seconds:%d' % (stepname, self.result_s, self.seconds))
    # DETAIL display
    print()
    print('DETAILS:')
    print()
    print('Backup sequence number: %d' % self.seqnum)
    for stepname in self.stepnames:
      self.set_step_variables(stepname)
      print('step:[%s],result:[%s],command:[%s],status/expected:%d/%d,seconds:%d,output:[%s],error:[%s],cmd_start:[%s],cmd_end:[%s]' %
            (stepname, self.result_s, self.command, self.status, self.expected_status, self.seconds,
             self.output, self.error, self.cmd_start_s, self.cmd_end_s))
    return # DONE

#--------------------------------------------------------------------------------------|
#   db_validate --rf2 <dir> --release_type full --neopw64 <pw> --exceptions_file e.csv |
#--------------------------------------------------------------------------------------|

def db_validate(arglist):
  saved_pwd = os.getcwd()
  opt = optparse.OptionParser()
  opt.add_option('--rf2',action='store',dest='rf2')
  opt.add_option('--release_type', action='store', dest='release_type', choices=['delta','snapshot','full'])
  opt.add_option('--neopw64', action='store', dest='neopw64')
  opt.add_option('--exceptions', action='store', dest='exceptions')
  opt.add_option('--logfile', action='store', dest='logfile', default='-')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==0 and opts.rf2 and opts.release_type and opts.neopw64):
    print('Usage: db_validate --rf2 <dir> --release_type full --neopw64 <base64pw>')
    sys.exit(1)
  # open logfile
  logfile = open(opts.logfile, 'w') if opts.logfile != '-' else sys.stdout
  #---------------------------------------------------------------------------
  # Determine SNOMED_G bin directory, where snomed_g_rf2_tools.py exists, etal
  #---------------------------------------------------------------------------
  pathsep = '/'
  # determine snomed_g_bin -- bin directory where snomed_g_rf2_tools.py exists in, etc -- try SNOMED_G_HOME, SNOMED_G_BIN env vbls
  # ... ask directly if these variables don't exist
  snomed_g_bin = os.environ.get('SNOMED_G_BIN',None) # unlikely to exist, but great if it does
  if not snomed_g_bin:
    snomed_g_home = os.environ.get('SNOMED_G_HOME',None)
    if snomed_g_home:
      snomed_g_bin = snomed_g_home.rstrip(pathsep) + pathsep + 'bin'
    else:
      snomed_g_bin = raw_input('Enter SNOMED_G bin directory path where snomed_g_rf2_tools.py exists: ').rstrip(pathsep)
  validated = False
  while not validated:
    if len(snomed_g_bin)==0:
      snomed_g_bin = raw_input('Enter SNOMED_G bin directory path where snomed_g_rf2_tools.py exists: ').rstrip(pathsep)
    else: # try to validate, look for snomed_g_rf2_tools.py
      target_file = snomed_g_bin+pathsep+'snomed_g_rf2_tools.py'
      validated = os.path.isfile(target_file)
      if not validated: print('Cant find [%s]' % target_file); snomed_g_bin = ''
  snomed_g_bin = os.path.abspath(snomed_g_bin)
  print('SNOMED_G bin directory [%s]' % snomed_g_bin)
  # connect to NEO4J, make sure information given is good
  neo4j = snomed_g_lib_neo4j.Neo4j_Access(base64.decodestring(opts.neopw64))
  # Connect to RF2 files, make sure rf2 directory given is good
  rf2_folders = snomed_g_lib_rf2.Rf2_Folders(opts.rf2, opts.release_type)
  # Build
  # open SQLITE database
  DB = StatusDb(os.path.abspath(opts.output_dir.rstrip(pathsep)+pathsep+'validate_status.db'))

  # create YYYYMMDD string
  d = datetime.datetime.now() # determine current date
  yyyymmdd = '%04d%02d%02d' % (d.year,d.month,d.day)
  job_start_datetime = datetime.datetime.now()

  # Commands needed to Create/Update a SNOMED_G Graph Database
  command_list_db_build = [
    {'stepname':'JOB_START',              'log':'JOB-START(release_type:[%s], rf2:[%s], date:[%s])' % (opts.release_type, opts.rf2, yyyymmdd)},
    {'stepname':'VALIDATE_CONCEPTS',      'cmd':'python %s/snomed_g_validate_graphdb_tools.py validate_graphdb --element concept      --release_type %s --rf2 %s --neopw64 %s' % (snomed_g_bin,opts.release_type,opts.rf2,opts.neopw64),
      'mode':['validate']},
    {'stepname':'VALIDATE_DESCRIPTIONS',  'cmd':'python %s/snomed_g_validate_graphdb_tools.py validate_graphdb --element description  --release_type %s --rf2 %s --neopw64 %s' % (snomed_g_bin,opts.release_type,opts.rf2,opts.neopw64),
      'mode':['validate']},
    {'stepname':'VALIDATE_ISA_RELS',      'cmd':'python %s/snomed_g_validate_graphdb_tools.py validate_graphdb --element isa_rel      --release_type %s --rf2 %s --neopw64 %s' % (snomed_g_bin,opts.release_type,opts.rf2,opts.neopw64),
      'mode':['validate']},
    {'stepname':'VALIDATE_DEFINING_RELS', 'cmd':'python %s/snomed_g_validate_graphdb_tools.py validate_graphdb --element defining_rel --release_type %s --rf2 %s --neopw64 %s' % (snomed_g_bin,opts.release_type,opts.rf2,opts.neopw64),
      'mode':['validate']},
    {'stepname':'JOB_END',                'log':'JOB-END'}
  ]
  command_list = command_list_db_build
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
    results_d[stepname]['error_count'] = 0 # default
    print(stepname)
    print(stepname, file=logfile) # indicate to user what step we are on
    if logmsg: # no command to execute in a separate process
      results_d[stepname]['status'] = 0
      results_d[stepname]['STDOUT'] = logmsg # LOG everything after 'LOG:'
      output, err = '', ''
    else: # execute command (cmd) in subprocess
      print(cmd, file=logfile)
      try:
        # SUBPROCESS creation
        cmd_as_list = cmd.split(' ')
        if opts.output_dir != '.': os.chdir(opts.output_dir) # move to output_dir, to start subprocess
        subprocess.check_call(cmd_as_list, stdout=logfile, stderr=logfile)
        if opts.output_dir !='.': os.chdir(saved_pwd) # get back (popd)
        status = 0 # if no exception -- status guaranteed to be zero
      except subprocess.CalledProcessError, e:
        status = e.returncode # by validate_graphdb convention, this code is the number of discrprancies found
        results_d[stepname]['status'] = status
        if status != expected_status:
          results_d[stepname]['result'] = 'FAILED (STATUS %d)' % status
          should_break = False # keep validating
        pass # might be fine, should_break controls termination
      except: # NOTE: result defaulted to -1 above
        results_d[stepname]['result'] = 'EXCEPTION occured -- on step [%s], cmd [%s]' % (stepname,cmd)
        should_break = True
        pass
      else: # no exception
        results_d[stepname]['status'] = status
        if status != expected_status:
          results_d[stepname]['result'] = 'FAILED (STATUS %d)' % status
          results_d[stepname]['error_count'] = status # graphdb_validate convention is to return discrprency count
          should_break = True # no steps are optional
    # Book-keeping
    cmd_end = datetime.datetime.now() # stop timer
    cmd_seconds = (cmd_end-cmd_start).seconds
    results_d[stepname]['elapsed_seconds'] = cmd_seconds
    if len(output) > 0: results_d[stepname]['STDOUT'] = output.replace('\n','<EOL>')
    if len(err) > 0: results_d[stepname]['STDERR'] = err.replace('\n','<EOL>')
    results_d[stepname]['cmd_start'] = cmd_start
    results_d[stepname]['cmd_end'] = cmd_end

    if should_break: break
  # Write results to the database
  save_and_report_results(DB, seqnum, stepnames, results_d)

  # Done
  sys.exit(0)
  return
# END db_validate

#----------------------------------------------------------------------------|
#                                MAIN                                        |
#----------------------------------------------------------------------------|

def parse_and_interpret(arglist):
  command_interpreters = [('validate_graphdb',validate_graphdb)]
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