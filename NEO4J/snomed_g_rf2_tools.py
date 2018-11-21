#!/usr/bin/python
from __future__ import print_function
import optparse, datetime, json, sys, base64, io
import snomed_g_lib_rf2, snomedct_constants

'''
Module:  snomed_g_rf2_tools.py
Author:  Jay Pedersen, July 2016
Purpose: Implement commands which support updating a SNOMED_G database.
            syntax: make_csv --element concept --release_type delta --rf2 <dir>
            semantics: given RF2 release, determine concept changes, create CSVs for import
Syntax and Semantics:
          python <pgm> make_csv --element concept --release_type delta/snapshot/full --rf2 <location>
                ==> creates cocncept_delta_FSN table in delta.db SQLITE file
                ==> accesses NEO4J graph at localhost
Example:
          python snomed_g_rf2_update_tools.py \
             make_csv --element concept --release_type snapshot \
                 --rf2 /cygdrive/c/sno/snomedct/SnomedCT_RF2Release_US1000124_20160301
'''


def make_utf8(v):
  if sys.version_info[0]==3:
    return v
  else: # py2.7 support
    return v if isinstance(v,unicode) else unicode( (str(v) if isinstance(v, int) else v) , "utf-8")


def clean_str(s):  #  result can be processed from a CSV file as a string
  return '"'+s.strip().replace('"',r'\"')+'"' # embedded double-quote processing


def csv_clean_str(s):
  return '"'+s.strip().replace('"','""').replace('\\','\\\\')+'"' # embedded double-quote processing


def chomp(s): # remove line ending.  <LF> or <CR><LF>
    return s.rstrip('\n').rstrip('\r')


# TIMING functions

def timing_start(timing_d, nm): timing_d[nm] = { 'start': datetime.datetime.now() }


def timing_end(timing_d, nm):   timing_d[nm]['end'] = datetime.datetime.now()


def show_timings(timestamps):
  for key in sorted(timestamps.keys()):
    delta = timestamps[key]['end'] - timestamps[key]['start']
    print('%-35s : %s' % (key, str(delta)))
# end show_timings

#--------------------------------------------------------------------------------
#             make_csv --element concept --rf2 <dir> --release_type delta       |
#--------------------------------------------------------------------------------

def make_csv(arglist):

  def rf2_filename(element, view=None): # rf2_folders is set in make_csv initialization
    return rf2_folders.rf2_file_path(element, view) # eg: 'concept'

  def old_compute_hist_changes(new_field_values, prev_field_values, field_names): # find map with only modified fields
    return { field_names[idx] : new_field_values[idx] for idx in range(len(field_names)) if make_utf8(new_field_values[idx]) != make_utf8(prev_field_values[idx]) }

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
    for nm in field_names: csv_data[csv_fields_d[nm]] = make_utf8(rf2_d[id][current_effTime][rf2_fields_d[renamed_fields.get(nm,nm)]])
    for k,v in non_rf2_fields: csv_data[csv_fields_d[k]] = make_utf8(v) # eg: [('history','<hist-json-str>'),...]
    if None in csv_data: raise ValueError('csv_data %s' % str(csv_data))
    for nm in quoted_fields: csv_data[csv_fields_d[nm]] = csv_clean_str(csv_data[csv_fields_d[nm]]) # quote only necessary fields
    return make_utf8( ','.join(csv_data) ) # output_line

  #------------------------------------------------------------------------------|
  #        CONCEPT CSV files creation -- concept_new.csv, concept_chg.csv        |
  #------------------------------------------------------------------------------|
  def testing_concept():
  
    def concept_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in concepts_d: concepts_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** Concept id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in concepts_d[id]: raise ValueError('*** Concept id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      concepts_d[id][effTime] = fields[:] # attributes in RF2-defined order
      rows_processed['n'] += 1 # tracks rows processed, --testing only

    def Fsn_cb(fields, fields_d, hist):
      ''' updates dictionary local to testing_concept -- all_Fsn_in_Rf2_d[conceptId] = FSN '''
      all_Fsn_in_Rf2_d[ make_utf8(fields[ fields_d['conceptId'] ]) ] = make_utf8(fields[ fields_d['term'] ]) # FSN

    def Fsn_filter(fields, fields_d, hist):
      ''' filter out any description that is not an active FSN '''
      return fields[ fields_d['typeId'] ] == snomedct_constants.SNOMEDCT_TYPEID_FSN and \
             fields[ fields_d['active'] ] == '1'

    # testing_concept:
    all_Fsn_in_Rf2_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('description') ).process_file(Fsn_cb, Fsn_filter, require_active=False)
    concepts_d = {}
    rows_processed = {'n': 0} # for --testing
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('concept') ).process_file(concept_cb, None, require_active=False)
    id_list = concepts_d.keys()
    print('Concepts: id_list size %d, definitions: %d (release type [%s])' % (len(id_list),rows_processed['n'],opts.release_type))
    return
 
  def make_concept_csvs():
  
    def concept_cb(fields, fields_d, hist):
      id, effTime = [fields[fields_d[x]] for x in ['id','effectiveTime']]
      if id not in concepts_d:
        concepts_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** Concept id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in concepts_d[id]: raise ValueError('*** Concept id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      concepts_d[id][effTime] = fields[:] # attributes in RF2-defined order

    def Fsn_cb(fields, fields_d, hist):
      ''' updates dictionary local to make_concept_csvs -- all_Fsn_in_Rf2_d[conceptId] = FSN '''
      all_Fsn_in_Rf2_d[ make_utf8(fields[ fields_d['conceptId'] ]) ] = make_utf8(fields[ fields_d['term'] ]) # FSN

    def Fsn_filter(fields, fields_d, hist):
      ''' filter out any description that is not an active FSN '''
      return fields[ fields_d['typeId'] ] == snomedct_constants.SNOMEDCT_TYPEID_FSN and \
             fields[ fields_d['active'] ] == '1'

    # make_concept_csvs:
    # ==> generate concept_new.csv, concept_chg.csv -- from info in RF2 and NEO4J
    stats = { 'no_change': 0, 'change': 0, 'new': 0 }
    timing_d = { }
    timing_idx = 0
    timing_overall_nm = '%04d_make_concept_csvs' % timing_idx; timing_start(timing_d, timing_overall_nm)
    timing_idx += 1; timing_nm = '%04d_read_RF2_description' % timing_idx; timing_start(timing_d, timing_nm)
    all_Fsn_in_Rf2_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('description') ).process_file(Fsn_cb, Fsn_filter, require_active=False) # active FSN only
    # ==> all_Fsn_in_Rf2_d set, indexed by sctid, all active FSNs in RF2 mapped to their concept ids
    timing_end(timing_d, timing_nm)
    f_new, f_chg = [io.open(x,'w',encoding='utf-8') for x in ['concept_new.csv','concept_chg.csv']]
    outfile_list = [f_new,f_chg]
    rf2_fields = attributes_by_file.rf2_fields['concept'] # [id,effectiveTime,active,moduleId,definitionStatusId] does NOT have FSN or history
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['concept'] # rf2_fields for 'concept' with ['FSN','history'] added on
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['FSN','history'] ] # exclude non-RF2 history and FSN (external)
    renamed_fields = attributes_by_file.renamed_fields['concept'] # dictionary, empty for concept
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['concept'] # history, term, descriptionType
    csv_header = make_utf8(','.join(csv_fields)) # "id,effectiveTime,...,FSN,history"
    for f in outfile_list: print(csv_header, file=f) # print header line for CSV files
    # create concepts_d with information from DELTA/SNAPSHOT/FULL concept file
    timing_idx += 1; timing_nm = '%04d_read_RF2_concept' % timing_idx; timing_start(timing_d, timing_nm)
    concepts_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('concept') ).process_file(concept_cb, None, require_active=False)
    # ==> created concepts_d[sctid][effTime] dictionary from RF2 Concept file
    timing_end(timing_d, timing_nm)
    rf2_idlist = concepts_d.keys()
    # ==> rf2_idlist is all concept ids from RF2 (from Concept file), regardless of whether active
    Fsn_d = { k: all_Fsn_in_Rf2_d[k] for k in list(set(all_Fsn_in_Rf2_d.keys()).intersection(set(rf2_idlist))) } # sets compare ascii+unicode
    print('count of RF2 ids: %d' % len(rf2_idlist))
    # Look for existing FSN values in graph
    print('count of FSNs in RF2: %d' % len(Fsn_d.keys()))
    if opts.action=='create':
      graph_matches_d = {} # No matches are possible as the graph does not yet exist.
    else:
      # NEO4J -- look for these concepts (N at a time)
      timing_idx += 1; timing_nm = '%04d_neo4j_lookup_concepts' % timing_idx; timing_start(timing_d, timing_nm)
      if opts.release_type=='delta':
        graph_matches_d = neo4j.lookup_concepts_for_ids(rf2_idlist) # This includes FSN values
      else:
        graph_matches_d = neo4j.lookup_all_concepts() # Includes FSN and history from graph
      timing_end(timing_d, timing_nm)
      print('Found %d of the IDs+FSNs in the graph DB:' % len(graph_matches_d.keys()))
      # Set any missing FSN values from the Graph
      target_id_set = set(graph_matches_d.keys()) - set(Fsn_d.keys())
      print('Id count in graph -- not in Fsn_d: %d' % len(target_id_set))
      print('Ids in graph -- not in Fsn_d:'); print(str(target_id_set))
      if len(target_id_set) > 0: # create report with the ids from graph, but not in concepts file
        with open('update__in_graph_but_not_RF2.txt','w') as f_rpt:
          print(json.dumps(list(target_id_set)),file=f_rpt)
      target_id_set = target_id_set.intersection(set(rf2_idlist))
      print('Id count in graph -- not in Fsn_d but in rf2_idlist (concepts): %d' % len(target_id_set))
      print('Ids in graph -- not in Fsn_d but in rf2_idlist:'); print(str(target_id_set))
      for id in list(target_id_set): Fsn_d[id] = graph_matches_d[id]['FSN']
      print('count of FSNs after merge with RF2 FSNs: %d' % len(Fsn_d.keys()))
    # Make sure all ids have an FSN
    Fsn_d_set, rf2_idlist_set = (set(Fsn_d.keys()), set(rf2_idlist))
    if Fsn_d_set != rf2_idlist_set:
        ids_without_FSNs = rf2_idlist_set - Fsn_d_set
        FSNs_without_ids = Fsn_d_set - rf2_idlist
        print('*** Missing FSNs for the following SCTID values:')
        print(ids_without_FSNs)
        print('*** FSNs without SCTID values:')
        print(FSNs_without_ids)
        raise ValueError('*** (sanity check failure) Cant find FSN for all IDs in release ***')
    # GENERATE CSV FILES
    timing_idx += 1; timing_nm = '%04d_generate_csvs' % timing_idx; timing_start(timing_d, timing_nm)
    f_temp_changed_fsn = io.open('temp_fsn_change.txt','w',encoding='utf-8') # DEBUG
    print(make_utf8('id\told_description\tnew_description'),file=f_temp_changed_fsn)
    for id in rf2_idlist:
      current_effTime = sorted(concepts_d[id].keys())[-1] # concepts_d[id] is a list of effectiveTime values, highest is current
      if id not in graph_matches_d: # not in graph ==> new
        stats['new'] += 1
      else: # in graph ==> change/no-change, definition change in Concept file or FSN change?
        the_same = False
        if graph_matches_d[id]['effectiveTime'] == concepts_d[id][current_effTime][rf2_fields_d['effectiveTime']]:
          if not id in all_Fsn_in_Rf2_d:
            the_same = True # odd case, no FSN in RF2, exception? (in graph, not in RF2)
            print('%%%% Found id [[[%s]]] in graph, but no description for it in the RF2 %%%%' % id)
          else:
            if graph_matches_d[id]['FSN'] == all_Fsn_in_Rf2_d[id]:
              the_same = True # use the FSN from the graph
            else: # DEBUG
              print(make_utf8('%s\t%s\t%s' % (id,graph_matches_d[id]['FSN'],all_Fsn_in_Rf2_d[id])),file=f_temp_changed_fsn)
        if the_same:
          stats['no_change'] += 1; continue # NO CHANGE ==> SKIP
        else:
          stats['change'] += 1 # concept changed or FSN changed
      hist_str = compute_history_string(id, concepts_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields)
      output_line = build_csv_output_line(id,[('FSN',Fsn_d[id]),('history',hist_str)],current_effTime, concepts_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      print(output_line,file=(f_new if not id in graph_matches_d else f_chg))
    # Done generating CSVs
    f_temp_changed_fsn.close() # DEBUG
    for nm in [timing_nm, timing_overall_nm]: timing_end(timing_d, nm)  # track timings
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list: f.close() # cleanup
    print('Total RF2 elements: %d, NEW: %d, CHANGE: %d, NO CHANGE: %d' % (len(rf2_idlist), stats['new'], stats['change'], stats['no_change']))
    show_timings(timing_d)
    return
  # END make_concept_csvs

  #------------------------------------------------------------------------------|
  #        DESCRIPTION CSV files  -- descrip_new.csv, descrip_chg.csv            |
  #------------------------------------------------------------------------------|
  def testing_description():

    def description_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in description_d: description_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** Concept id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in description_d[id]: raise ValueError('*** Concept id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      description_d[id][effTime] = fields[:] # attributes in RF2-defined order
      rows_processed['n'] += 1 # tracks rows processed, --testing only
    def language_cb(fields, fields_d, hist):
      id = fields[ fields_d['referencedComponentId'] ]
      if id in language_d and language_d[id]['refsetId']==snomedct_constants.SNOMEDCT_REFSETID_USA: return # prefer US def
      language_d[id] = { nm : fields[ fields_d[nm] ] for nm in fields_d.keys() }
    def snapshot_language_cb(fields, fields_d, hist):
      id = fields[ fields_d['referencedComponentId'] ]
      if id in snapshot_language_d and snapshot_language_d[id]['refsetId']==snomedct_constants.SNOMEDCT_REFSETID_USA: return # prefer US def
      snapshot_language_d[id] = { nm : fields[ fields_d[nm] ] for nm in fields_d.keys() }
    def compute_descriptionType(typeId,acceptabilityId):
      return 'FSN' if typeId=='900000000000003001' \
             else 'Preferred' if typeId=='900000000000013009' and acceptabilityId=='900000000000548007' \
             else 'Synonym'

    # testing_description
    description_d, language_d, snapshot_language_d = {}, {}, {}
    rows_processed = { 'n': 0 } # cant simply use rows_processed = 0 and have it available in description_cb, map works
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('description') ).process_file(description_cb, None, require_active=False)
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('language') ).process_file(language_cb, None, require_active=False)
    id_list = description_d.keys()
    print('Descriptions: id_list size %d, definitions: %d (release type [%s])' % (len(id_list),rows_processed['n'],opts.release_type))
    return

  def make_description_csvs():

    def description_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in description_d: description_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** Concept id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in description_d[id]: raise ValueError('*** Concept id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
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

    # make_description_csvs:
    # ==> generate descrip_new.csv, descrip_chg.csv -- from info in RF2 and NEO4J
    stats = { 'no_change': 0, 'change': 0, 'new': 0, 'no_language': 0 }
    timing_d = {}
    timing_idx = 0
    timing_overall_nm = '%04d_make_description_csvs' % timing_idx; timing_start(timing_d, timing_overall_nm)
    # READ RF2 DESCRIPTION FILE
    timing_idx += 1; timing_nm = '%04d_read_RF2_description' % timing_idx; timing_start(timing_d, timing_nm)
    description_d, language_d, snapshot_language_d = {}, {}, {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('description') ).process_file(description_cb, None, require_active=False)
    timing_end(timing_d, timing_nm)
    rf2_idlist = description_d.keys()
    print('count of RF2 ids: %d' % len(rf2_idlist))
    # READ RF2 LANGUAGE FILE
    timing_idx += 1; timing_nm = '%04d_read_RF2_language' % timing_idx; timing_start(timing_d, timing_nm)
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('language') ).process_file(language_cb, None, require_active=False)
    timing_end(timing_d, timing_nm)
    if opts.release_type=='delta': # need snapshot file for fallback of potential missing historical information
      print('read snapshot language values');
      timing_idx += 1; timing_nm = '%04d_read_rf2_language_snapshot' % timing_idx; timing_start(timing_d, timing_nm)
      snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('language','Snapshot') ).process_file(snapshot_language_cb, None, require_active=False); print('read')
      timing_end(timing_d, timing_nm)
    # CSV INIT, ATTRIBUTE NAMES MANAGEMENT
    f_new, f_chg = [io.open(x,'w',encoding='utf-8') for x in ['descrip_new.csv','descrip_chg.csv']]
    outfile_list = [f_new,f_chg]
    rf2_fields = attributes_by_file.rf2_fields['description']
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['description'] # ['id','effectiveTime','active',...,'history']
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['id128bit','acceptabilityId','refsetId','descriptionType','history'] ]
    renamed_fields = attributes_by_file.renamed_fields['description'] # dictionary
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['description']
    csv_header = make_utf8(','.join(csv_fields)) # "id,effectiveTime,..."
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
    no_language_example_code = ''
    for id in rf2_idlist:
      current_effTime = sorted(description_d[id].keys())[-1] # highest effectiveTime is current
      if id not in graph_matches_d: # not in graph ==> new
        stats['new'] += 1
      else: # in graph ==> change/no-change
        if description_d[id][current_effTime][rf2_fields_d['effectiveTime']] == graph_matches_d[id]['effectiveTime']:
          stats['no_change'] += 1
          continue # NO CHANGE ==> CONTINUE ==> NO ADDITIONAL PROCESSING FOR THIS ENTRY
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
        if stats['no_language']==1: no_language_example_code = id
      non_rf2_fields = [(x,computed[x]) for x in ['id128bit','acceptabilityId','refsetId','descriptionType']]+[('history',hist_str)]
      output_line = build_csv_output_line(id, non_rf2_fields, current_effTime, description_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      print(output_line,file=(f_new if not id in graph_matches_d else f_chg))
    # Done generating CSVs
    for nm in [timing_nm, timing_overall_nm]: timing_end(timing_d, nm)  # track timings
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list: f.close() # cleanup
    if stats['no_language'] > 0:
      print('[[[ NOTE: Did not find Refset/Language records for %d concepts, e.g. sctid: [%s] ]]]'
            % (stats['no_language'], no_language_example_code))
    print('Total RF2 elements: %d, NEW: %d, CHANGE: %d, NO CHANGE: %d' % (len(rf2_idlist), stats['new'], stats['change'], stats['no_change']))
    show_timings(timing_d)
    # DONE
    for f in outfile_list: f.close() # cleanup
    return
  # END make_description_csvs

  #------------------------------------------------------------------------------|
  #            ISA_REL CSV files  -- isa_rel_new.csv, isa_rel_chg.csv            |
  #------------------------------------------------------------------------------|
  def testing_isa_rel():

    def isa_rel_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in isa_rel_d: isa_rel_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** ISA id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in isa_rel_d[id]: raise ValueError('*** ISA id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      isa_rel_d[id][effTime] = fields[:] # attributes in RF2-defined order
      rows_processed['n'] += 1 # tracks rows processed, --testing only
    def isa_rel_filter(fields, fields_d, hist):
      return fields[ fields_d['typeId'] ] == snomedct_constants.SNOMEDCT_TYPEID_ISA

    # testing_isa_rel:
    isa_rel_d = {}
    rows_processed = { 'n': 0 } 
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('relationship') ).process_file(isa_rel_cb, isa_rel_filter, require_active=False)
    id_list = isa_rel_d.keys()
    print('ISA: id_list size %d, definitions: %d (release type [%s])' % (len(id_list),rows_processed['n'],opts.release_type))
    return
 
  def make_isa_rel_csvs():

    def isa_rel_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in isa_rel_d: isa_rel_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** ISA id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in isa_rel_d[id]: raise ValueError('*** ISA id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      isa_rel_d[id][effTime] = fields[:] # attributes in RF2-defined order
    def isa_rel_filter(fields, fields_d, hist):
      return fields[ fields_d['typeId'] ] == snomedct_constants.SNOMEDCT_TYPEID_ISA

    # make_isa_rel_csvs:
    # ==> generate isa_rel_new.csv, isa_rel_chg.csv -- from info in RF2 and NEO4J
    stats = { 'no_change': 0, 'change': 0, 'new': 0 }
    timing_d = {}
    timing_idx = 0
    timing_overall_nm = '%04d_make_isa_rels_csvs' % timing_idx; timing_start(timing_d, timing_overall_nm)
    # READ RF2 RELATIONSHIP FILE - EXTRACT ISA
    timing_idx += 1; timing_nm = '%04d_read_RF2_relationship' % timing_idx; timing_start(timing_d, timing_nm)
    isa_rel_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('relationship') ).process_file(isa_rel_cb, isa_rel_filter, require_active=False)
    timing_end(timing_d, timing_nm)
    rf2_idlist = isa_rel_d.keys()
    print('count of ids in RF2: %d' % len(rf2_idlist))
    # CSV FILE INIT, ATTRIBUTE NAME MANAGEMENT
    f_new, f_chg = [io.open(x,'w',encoding='utf-8') for x in ['isa_rel_new.csv','isa_rel_chg.csv']]
    outfile_list = [f_new,f_chg]
    rf2_fields = attributes_by_file.rf2_fields['isa_rel']
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['isa_rel'] # ['id','effectiveTime','active',...,'history']
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['history'] ]
    renamed_fields = attributes_by_file.renamed_fields['isa_rel'] # dictionary
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['isa_rel']
    csv_header = make_utf8(','.join(csv_fields)) # "id,effectiveTime,..."
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
      if id not in graph_matches_d: # not in graph ==> new
        stats['new'] += 1
      else: # in graph ==> change/no-change
        if isa_rel_d[id][current_effTime][rf2_fields_d['effectiveTime']] == graph_matches_d[id]['effectiveTime']:
          stats['no_change'] += 1
          continue # NO CHANGE ==> CONTINUE ==> NO ADDITIONAL PROCESSING FOR THIS ENTRY
        stats['change'] += 1
      hist_str = compute_history_string(id, isa_rel_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields)
      output_line = build_csv_output_line(id,[('history',hist_str)],current_effTime, isa_rel_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      print(output_line,file=(f_new if not id in graph_matches_d else f_chg))
    # Done generating CSVs
    for nm in [timing_nm, timing_overall_nm]: timing_end(timing_d, nm)  # track timings
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list: f.close() # cleanup
    print('Total RF2 elements: %d, NEW: %d, CHANGE: %d, NO CHANGE: %d' % (len(rf2_idlist), stats['new'], stats['change'], stats['no_change']))
    show_timings(timing_d)
    return
  # END make_isa_rel_csvs

  #------------------------------------------------------------------------------|
  #    DEFINING_REL CSV files  -- defining_rel_new.csv, defining_rel_chg.csv     |
  #------------------------------------------------------------------------------|
  def testing_defining_rel():

    def defining_rel_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in defining_rel_d: defining_rel_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** DEFINING-REL id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in defining_rel_d[id]: raise ValueError('*** DEFINING-REL id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      defining_rel_d[id][effTime] = fields[:] # attributes in RF2-defined order
      rows_processed['n'] += 1 # tracks rows processed, --testing only
    def defining_rel_filter(fields, fields_d, hist):
      return fields[ fields_d['typeId'] ] != snomedct_constants.SNOMEDCT_TYPEID_ISA

    # testing_defining_rel:
    defining_rel_d = {}
    rows_processed = { 'n': 0 }
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('relationship') ).process_file(defining_rel_cb, defining_rel_filter, require_active=False)
    id_list = defining_rel_d.keys()
    print('DEFINING rels: id_list size %d, definitions: %d (release type [%s])' % (len(id_list),rows_processed['n'],opts.release_type))
    return

  def make_defining_rel_csvs():

    def defining_rel_cb(fields, fields_d, hist):
      id = fields[ fields_d['id'] ]
      effTime = fields[ fields_d['effectiveTime'] ]
      if id not in defining_rel_d: defining_rel_d[id] = {} # not seen before -- empty dictionary (keyed by effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** DEFINING-REL id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in defining_rel_d[id]: raise ValueError('*** DEFINING-REL id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      defining_rel_d[id][effTime] = fields[:] # attributes in RF2-defined order
    def defining_rel_filter(fields, fields_d, hist):
      return fields[ fields_d['typeId'] ] != snomedct_constants.SNOMEDCT_TYPEID_ISA

    # make_defining_rel_csvs:
    # ==> generate defining_rel_new.csv, defining_rel_chg.csv -- from info in RF2 and NEO4J
    stats = { 'no_change': 0, 'change': 0, 'new': 0 }
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
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('relationship') ).process_file(defining_rel_cb, defining_rel_filter, require_active=False)
    timing_end(timing_d, timing_nm)
    rf2_idlist = defining_rel_d.keys()
    print('count of ids in RF2: %d' % len(rf2_idlist))
    # CSV FILE INIT, ATTRIBUTE NAME MANAGEMENT
    f_new, f_chg, f_edge_rem = [io.open(x,'w',encoding='utf-8') \
                                for x in ['defining_rel_new.csv','defining_rel_chg.csv','defining_rel_edge_rem.csv']]
    print(make_utf8('id,rolegroup,sourceId,destinationId'),file=f_edge_rem)
    outfile_list = [f_new,f_chg]
    f_DRs = {} # per-defining-relationship type
    rf2_fields = attributes_by_file.rf2_fields['defining_rel']
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['defining_rel'] # ['id','effectiveTime','active',...,'history']
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['history'] ]
    renamed_fields = attributes_by_file.renamed_fields['defining_rel'] # dictionary
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['defining_rel']
    csv_header = make_utf8(','.join(csv_fields)) # "id,effectiveTime,..."
    for f in outfile_list: print(csv_header, file=f) # header
    if opts.action == 'create':
      graph_matches_d = {} # no existing graph, no matches
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
      if id not in graph_matches_d: # not in graph ==> new
        stats['new'] += 1
      else: # in graph ==> change/no-change
        if defining_rel_d[id][current_effTime][rf2_fields_d['effectiveTime']] == graph_matches_d[id]['effectiveTime']:
          stats['no_change'] += 1 # NO CHANGE IN THIS RELATIONSHIP (common situation)
          continue  # NO CHANGE ==> CONTINUE ==> NO ADDITIONAL PROCESSING FOR THIS ENTRY
        stats['change'] += 1 # effectiveTime changed ==> defining relationship changed
        # see if rolegroup changed
        if graph_matches_d[id]['rolegroup'] != defining_rel_d[id][current_effTime][ rf2_fields_d['relationshipGroup'] ]: # rolegroup change?
          print('%s,%s,%s,%s' % (id,graph_matches_d[id]['rolegroup'],graph_matches_d[id]['sctid'],graph_matches_d[id]['destinationId']),file=f_edge_rem)
          rolegroup_changed = True # treat this as an edge create case
      if current_typeId not in f_DRs: # this could occur on a 'new', but also 'change'
        f_DRs[current_typeId] = open('DR_%s_new.csv' % current_typeId,'w'); print(csv_header, file=f_DRs[current_typeId])
        print('%s,%s' % (current_typeId, roleHash[current_typeId]), file=f_used_roles)
      hist_str = compute_history_string(id, defining_rel_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields)
      output_line = build_csv_output_line(id,[('history',hist_str)],current_effTime, defining_rel_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      output_files = [f_chg] if (rolegroup_changed==False and id in graph_matches_d) else [f_new, f_DRs[current_typeId]]
      for f in output_files: print(output_line, file=f)
    # Done generating CSVs
    for nm in [timing_nm, timing_overall_nm]: timing_end(timing_d, nm) # track timings
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list+[f_edge_rem]+[f_DRs[typeId] for typeId in f_DRs.keys()]+[f_used_roles]: f.close() # cleanup
    print('Total RF2 elements: %d, NEW: %d, CHANGE: %d, NO CHANGE: %d' % (len(rf2_idlist), stats['new'], stats['change'], stats['no_change']))
    show_timings(timing_d)
    return
  # END make_defining_rel_csvs

  def make_association_refset_csvs():
    def association_refset_cb(fields, fields_d, hist): # callback when processing association-refset file, load association_refset_d
      id = fields[fields_d['id']]
      effTime = fields[fields_d['effectiveTime']]
      if id not in association_refset_d: association_refset_d[id] = {} # not seen before -- empty dictionary (keyed by id+effectiveTime)
      else:
        if opts.release_type != 'full': raise ValueError('*** ASSOCIATION id [%s] with multiple entries in [%s] release-type, should NOT occur ***' % (id,opts.release_type))
        if effTime in association_refset_d[id]: raise ValueError('*** ASSOCIATION id [%s] with duplicate effectiveTime [%s], should NOT occur ***' % (id, effTime))
      association_refset_d[id][effTime] = fields[:] # attributes in RF2-defined order

    # make_association_refset_csvs:
    # ==> generate association_refset_new.csv, association_refset_chg.csv -- from info in RF2 and NEO4J
    stats = { 'no_change': 0, 'change': 0, 'new': 0 }
    timing_d = {}
    timing_idx = 0
    timing_overall_nm = '%04d_make_association_refsets_csvs' % timing_idx; timing_start(timing_d, timing_overall_nm)
    # Define association names mapping to refsetId
    assoc_names = {
    '900000000000523009': 'POSSIBLY EQUIVALENT TO',
    '900000000000524003': 'MOVED TO',
    '900000000000525002': 'MOVED FROM',
    '900000000000530003': 'ALTERNATIVE',
    '900000000000531004': 'REFERS TO',
    '900000000000526001': 'REPLACED BY',
    '900000000000527005': 'SAME AS',
    '900000000000528000': 'WAS A',
    '900000000000529008': 'SIMILAR TO'
    }
    # READ RF2 ASSOCIATION REFSET FILE - EXTRACT HISTORICAL CONCEPT ASSOCIATIONS
    timing_idx += 1; timing_nm = '%04d_read_RF2_association_refset' % timing_idx; timing_start(timing_d, timing_nm)
    association_refset_d = {}
    snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('association_refset') ).process_file(association_refset_cb, None, require_active=False)
    timing_end(timing_d, timing_nm)
    rf2_idlist = association_refset_d.keys()
    print('count of ids in RF2: %d' % len(rf2_idlist))
    # CSV FILE INIT, ATTRIBUTE NAME MANAGEMENT
    f_new, f_chg = [io.open(x,'w',encoding='utf-8') for x in ['association_refset_new.csv','association_refset_chg.csv']]
    outfile_list = [f_new,f_chg]
    rf2_fields = attributes_by_file.rf2_fields['association_refset']
    rf2_fields_d = { nm: idx for idx,nm in enumerate(rf2_fields) }
    csv_fields = attributes_by_file.csv_fields['association_refset'] # ['id','effectiveTime','active',...,'history']
    csv_fields_d = { nm: idx for idx,nm in enumerate(csv_fields) }
    field_names = [ x for x in csv_fields if x not in ['history','association'] ] # since 'association' computed -- issue with build_csv_output_line
    renamed_fields = attributes_by_file.renamed_fields['association_refset'] # dictionary
    quoted_in_csv_fields = attributes_by_file.quoted_in_csv_fields['association_refset']
    csv_header = make_utf8(','.join(csv_fields)) # "id,effectiveTime,..."
    for f in outfile_list: print(csv_header, file=f) # header
    if opts.action == 'create':
      graph_matches_d = {}
    else:
      # EXTRACT ASSOCIATION REFSET RELATIONSHIPS FROM NEO4J (TODO, 2016-10-05)
      #timing_idx += 1; timing_nm = '%04d_get_neo4j_association_refsetS' % timing_idx; timing_start(timing_d, timing_nm)
      #all_in_graph = neo4j.lookup_all_association_refsets() # looking for rel by its 'id' is SLOOOOOOW, get them ALL instead
      #timing_end(timing_d, timing_nm)
      #print('count of ALL ASSOCIATION relationships in NEO4J: %d' % len(all_in_graph.keys()))
      #graph_matches_d = { x: all_in_graph[x] for x in list(set(all_in_graph.keys()).intersection(set(rf2_idlist))) } # successful compare ascii+unicode, way faster than "if" test
      #print('count of ASSOCIATION in NEO4J: %d' % len(graph_matches_d.keys()))
      print('*** Only CREATE currently supported for ASSOCIATION REFSET ***')
      return # for now, since TBD, only opts.action=='CREATE" supported as of Oct 5, 2016
    # GENERATE CSV FILES FOR NEW AND CHG
    timing_idx += 1; timing_nm = '%04d_csv_generation' % timing_idx; timing_start(timing_d, timing_nm)
    for id in rf2_idlist: # must compute updated history for each
      current_effTime = sorted(association_refset_d[id].keys())[-1] # highest effectiveTime is current
      if id not in graph_matches_d: # not in graph ==> new
        stats['new'] += 1
      else: # in graph ==> change/no-change
        if association_refset_d[id][current_effTime][rf2_fields_d['effectiveTime']] == graph_matches_d[id]['effectiveTime']:
          stats['no_change'] += 1
          continue # NO CHANGE ==> CONTINUE ==> NO ADDITIONAL PROCESSING FOR THIS ENTRY
        stats['change'] += 1
      hist_str = compute_history_string(id, association_refset_d, graph_matches_d, field_names, rf2_fields_d, renamed_fields)
      #print('computed history JSON: [%s]' % hist_str)
      output_line = build_csv_output_line(id,[('history',hist_str),('association',assoc_names[association_refset_d[id][current_effTime][rf2_fields_d['refsetId']]])],
                                          current_effTime, association_refset_d, csv_fields_d, field_names, rf2_fields_d, renamed_fields, quoted_in_csv_fields)
      print(output_line,file=(f_new if not id in graph_matches_d else f_chg))
    # Done generating CSVs
    for nm in [timing_nm, timing_overall_nm]: timing_end(timing_d, nm)  # track timings
    # CLEANUP, DISPLAY RESULTS
    for f in outfile_list: f.close() # cleanup
    print('Total RF2 elements: %d, NEW: %d, CHANGE: %d, NO CHANGE: %d' % (len(rf2_idlist), stats['new'], stats['change'], stats['no_change']))
    show_timings(timing_d)
    return
  # END make_association_refset_csvs

  # make_csv:
  # Output: specified CSV file, all fields that were extracted
  opt = optparse.OptionParser()
  opt.add_option('--verbose', action='store_true')
  opt.add_option('--rf2', action='store')
  opt.add_option('--element', action='store', choices=['concept','description','isa_rel','defining_rel','association_refset'])
  opt.add_option('--release_type', action='store', choices=['delta','snapshot','full'])
  opt.add_option('--action', action='store', default='create', choices=['create','update'])
  opt.add_option('--neopw64', action='store')
  opt.add_option('--neopw', action='store')
  opt.add_option('--testing', action='store_true', dest='testing')
  opt.add_option('--relationship_file', action='store', default='Relationship')
  opt.add_option('--language_code', action='store', default='en')
  opt.add_option('--language_name', action='store', default='Language')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==0 and opts.rf2 and opts.element and opts.release_type):
    print('Usage: make_csv --element concept/description/isa_rel/defining_rel/association_refset --rf2 <dir> --release_type delta/snapshot --action create/update')
    sys.exit(1)
  # Connect to NEO4J
  #neopw = base64.decodestring( json.loads(open('necares_config.json').read())['salt'] )
  if opts.neopw and opts.neopw64:
    print('Usage: only one of --neopw and --neopw64 may be specified')
    sys.exit(1)
  if opts.neopw64: # snomed_g v1.2, convert neopw64 to neopw
      opts.neopw = str(base64.b64decode(opts.neopw64),'utf-8') if sys.version_info[0]==3 else base64.decodestring(opts.neopw64) # py2
  if opts.action in ['update']:
    import snomed_g_lib_neo4j # just-in-time import
    neo4j = snomed_g_lib_neo4j.Neo4j_Access(opts.neopw)
  else:
    neo4j = None # not needed for 'create'
  # Connect to RF2 files
  rf2_folders = snomed_g_lib_rf2.Rf2_Folders(opts.rf2, opts.release_type, opts.relationship_file, opts.language_code, opts.language_name)
  # Information for creating the CSV files
  attributes_by_file = snomed_g_lib_rf2.Rf2_Attributes_per_File()
  # testing (make_csv --testing, for debugging purposes)
  if opts.testing:
    if   opts.element=='concept':      testing_concept()
    elif opts.element=='isa_rel':      testing_isa_rel()
    elif opts.element=='defining_rel': testing_defining_rel()
    elif opts.element=='description':  testing_description()
    return # NOTE: nothing for association_refset, no testing defined for it
  # determine the fields names, NOTE: history is assumed as added last field
  if   opts.element=='concept':      make_concept_csvs()
  elif opts.element=='description':  make_description_csvs()
  elif opts.element=='isa_rel':      make_isa_rel_csvs()
  elif opts.element=='defining_rel': make_defining_rel_csvs()
  elif opts.element=='association_refset': make_association_refset_csvs()
  else:
    print('element [%s] NOT SUPPORTED (yet)' % opts.element); sys.exit(1)
  return
# end make_csv

#----------------------------------------------------------------------------|
#                           FIND_ROLEGROUPS                                  |
#----------------------------------------------------------------------------|
def find_rolegroups(arglist):

  def rf2_filename(element, view=None): # rf2_folders is set in make_csv initialization
    return rf2_folders.rf2_file_path(element, view) # eg: 'concept'

  def defining_rel_filter(fields, fields_d, hist):
    return fields[fields_d['typeId']] != snomedct_constants.SNOMEDCT_TYPEID_ISA

  def defining_rel_cb(fields, fields_d, hist):
    sctid, rolegroup = fields[fields_d['sourceId']], fields[fields_d['relationshipGroup']]
    key = '%s_%s' % (sctid,rolegroup)
    if key not in rolegroupHash: rolegroupHash[key] = None # only keys are needed

  # find_rolegroups:
  opt = optparse.OptionParser()
  opt.add_option('--verbose',action='store_true',dest='verbose')
  opt.add_option('--rf2',action='store',dest='rf2')
  opt.add_option('--release_type', action='store', dest='release_type', choices=['delta','snapshot','full'])
  opt.add_option('--relationship_file', action='store', dest='relationship_file', default='Relationship')
  opt.add_option('--language_code', action='store', dest='language_code', default='en')
  opt.add_option('--language_name', action='store', dest='language_name', default='Language')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==0 and opts.rf2 and opts.release_type):
    print('Usage: make_csv --rf2 <dir> --release_type delta/snapshot/full')
    sys.exit(1)

  # Connect to RF2 files
  rf2_folders = snomed_g_lib_rf2.Rf2_Folders(opts.rf2, opts.release_type, opts.relationship_file, opts.language_code, opts.language_name)

  # Process all concepts -- find the relationship concepts and associated FSN
  rolegroupHash = {} # prep
  snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('relationship') ).process_file(defining_rel_cb, defining_rel_filter, require_active=False)

  # generate rolegroups.csv
  with open('rolegroups.csv', 'w') as fout:
    print('sctid,rolegroup', file=fout)
    for key in rolegroupHash.keys(): print('%s,%s' % tuple(key.split('_')), file=fout) # key is <sctid>_<rolegroup>
  return

#----------------------------------------------------------------------------|
#                           FIND_ROLENAMES                                   |
#----------------------------------------------------------------------------|
def find_rolenames(arglist):

  def rf2_filename(element, view=None): # rf2_folders is set in make_csv initialization
    return rf2_folders.rf2_file_path(element, view) # eg: 'concept'

  def defining_rel_filter(fields, fields_d, hist): # all non-ISA relationships are defining relationships
    return fields[fields_d['typeId']] != snomedct_constants.SNOMEDCT_TYPEID_ISA

  def defining_rel_cb(fields, fields_d, hist):
    if fields[fields_d['typeId']] not in roleHash: roleHash[fields[fields_d['typeId']]] = None # placeholder

  def Fsn_cb(fields, fields_d, hist):
    ''' Callback from Description file.
        Sets roleHash for the concept associated with a description.
        NOTES: 
        1. The Fsn_filter guarantees that we are processing an active FSN description record
           for a concept known to have been used in a defining relationship (and is thus a role).
        2. The term for the description is used for the role name.
        3. We may be processing a FULL release, use most recent definition based on effectiveTime.
    '''
    sctid, effTime   = fields[fields_d['conceptId']], fields[fields_d['effectiveTime']]
    rolename = make_utf8(role_name(fields[ fields_d['term'] ])) # NOTE: role_name transforms term to role name
    if roleHash[sctid]==None or effTime > roleHash[sctid]['effectiveTime']:
      roleHash[sctid] = { 'effectiveTime': effTime, 'rolename': rolename }

  def Fsn_filter(fields, fields_d, hist):
    ''' filter any description that is not for a determined role or that is not an active FSN '''
    return fields[fields_d['conceptId']] in roleHash and \
           fields[fields_d['typeId']] == snomedct_constants.SNOMEDCT_TYPEID_FSN and \
           fields[fields_d['active']] == '1'

  def role_name(s): # convert FSN for defining concept role into displayable name, eg: FINDING_SITE
    return s.replace(' (attribute)','').replace(' ','_').replace('"','').replace('-','').replace('(','').replace(')','').replace('___','_').upper()

  # make_all_roles:
  opt = optparse.OptionParser()
  opt.add_option('--verbose',action='store_true',dest='verbose')
  opt.add_option('--rf2',action='store',dest='rf2')
  opt.add_option('--release_type', action='store', dest='release_type', choices=['delta','snapshot','full'])
  opt.add_option('--relationship_file', action='store', dest='relationship_file', default='Relationship')
  opt.add_option('--language_code', action='store', dest='language_code', default='en')
  opt.add_option('--language_name', action='store', dest='language_name', default='Language')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==0 and opts.rf2 and opts.release_type):
    print('Usage: make_csv --rf2 <dir> --release_type delta/snapshot/full')
    sys.exit(1)

  # Connect to RF2 files
  rf2_folders = snomed_g_lib_rf2.Rf2_Folders(opts.rf2, opts.release_type, opts.relationship_file, opts.language_code, opts.language_name)

  # Process all concepts -- find the relationship concepts and associated FSN
  roleHash = {} # prep
  snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('relationship') ).process_file(defining_rel_cb, defining_rel_filter, require_active=False)
  snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('description') ).process_file(Fsn_cb, Fsn_filter, require_active=False) # TODO - what of 'Delta' case?
  # NOTE: for 'Delta' case -- we could allow the user to provide an 'all_roles.csv' file specifying the role names

  # generate all_roles.csv
  with open('all_roles.csv', 'w') as fout:
    print('role,rolename', file=fout)
    for role in roleHash.keys(): print('%s,%s' % (role, roleHash[role]['rolename'] if roleHash[role] != None else 'ROLE_%s' % role), file=fout)
  return
# END find_rolenames

#------------------------------------------------------------------------------|
#                 get_id_active_fsn --rf2 <dir> <out-file>                     |
#                                                                              |
# Purpose: NOT very abstract, specifically get snomed concept code, FSN, and   |
#          active state and write to a file.  Could make this more abstract    |
#          and specify the list of attributes (possibly processing multi files)|
#------------------------------------------------------------------------------|

def get_id_active_fsn(arglist):
  def rf2_filename(element, view=None): # rf2_folders is set in make_csv initialization
    return rf2_folders.rf2_file_path(element, view) # eg: 'concept'
  def concept_cb(fields, fields_d, hist):
    ''' Callback from Concept file.
        Sets idHash for the concept being processed
        NOTES: 
        1. There is no filter, all records are processed (i.e. multiple historical records for one concept).
        2. We may be processing a FULL release, use most recent definition based on effectiveTime.
    '''
    sctid, effTime, active = [fields[fields_d[x]] for x in ['id','effectiveTime','active']]
    if sctid not in idHash:
      idHash[sctid] = { 'effectiveTime': effTime, 'active': active}
    elif effTime > idHash[sctid]['effectiveTime']:
      idHash[sctid] = { 'effectiveTime': effTime, 'active': active}
  def Fsn_filter(fields, fields_d, hist):
    ''' filter out any description that is not an active FSN '''
    return fields[ fields_d['typeId'] ] == snomedct_constants.SNOMEDCT_TYPEID_FSN and \
           fields[ fields_d['active'] ] == '1'
  def Fsn_cb(fields, fields_d, hist):
    ''' Callback from Description file.
        Set fsnHash for the concept associated with this description.
        NOTES: 
        1. The Fsn_filter guarantees that we are processing an active FSN description.
        2. We may be processing a FULL release, use most recent definition based on effectiveTime.
    '''
    sctid, effTime, fsn = [fields[fields_d[x]] for x in ['conceptId','effectiveTime','term']]
    if sctid not in fsnHash:
      fsnHash[sctid] = { 'effectiveTime': effTime, 'FSN': fsn}
    elif effTime > fsnHash[sctid]['effectiveTime']:
      fsnHash[sctid] = { 'effectiveTime': effTime, 'FSN': fsn}

  # get_id_active_fsn:
  opt = optparse.OptionParser()
  opt.add_option('--rf2',action='store',dest='rf2')
  opt.add_option('--release_type', action='store', dest='release_type', choices=['delta','snapshot','full'])
  opt.add_option('--relationship_file', action='store', dest='relationship_file', default='Relationship')
  opt.add_option('--language_code', action='store', dest='language_code', default='en')
  opt.add_option('--language_name', action='store', dest='language_name', default='Language')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==1 and opts.rf2 and opts.release_type):
    print('Usage: get_id_active_fsn --rf2 <dir> --release_type delta/snapshot/full')
    sys.exit(1)

  # Connect to RF2 files
  rf2_folders = snomed_g_lib_rf2.Rf2_Folders(opts.rf2, opts.release_type, opts.relationship_file, opts.language_code, opts.language_name)

  # Process all concepts -- find the id and active state (for latest effectiveTime)
  idHash = {} # prep
  fsnHash = {}
  snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('concept') ).process_file(concept_cb, None, require_active=False)
  snomed_g_lib_rf2.Process_Rf2_Release_File( rf2_filename('description') ).process_file(Fsn_cb, Fsn_filter, require_active=False)

  # generate specified output file
  with open(args[0], 'w') as fout:
    print('id,active,effectiveTime,FSN', file=fout)
    for id in idHash.keys(): print('%s,%s,%s,%s' % (csv_clean_str(id), csv_clean_str(idHash[id]['active']), csv_clean_str(idHash[id]['effectiveTime']), csv_clean_str(fsnHash[id]['FSN'])), file=fout)
  return
# END get_id_active_fsn

#------------------------------------------------------------------------------|
#        set_missing_efftime <yyyymmdd> <in-rf2-file> <out-rf2-file>           |
#                                                                              |
# Purpose: Any record where the effectiveTime is empty is set to the value     |
#          specified in the command (yyyymmdd).                                |
#------------------------------------------------------------------------------|

def set_missing_efftime(arglist):

  def rf2_file_callback(infile_fnam, outfile_fnam):
    fin, fout = io.open(infile_fnam,'r',encoding='utf-8'),io.open(outfile_fnam,'w',encoding='utf-8')
    rawline = fin.readline() # try to read header line (may not exist, file might be empty)
    if rawline: # header line exists, not empty file
      line = rawline.rstrip('\n').rstrip('\r')
      print(line, file=fout) # print header line
      header_fields = line.split('\t')
      target_field_idx = None if 'effectiveTime' not in header_fields else header_fields.index('effectiveTime')
      replacements = 0
      while True:
        rawline = fin.readline()
        if not rawline: break # EOF
        line = rawline.rstrip('\n').rstrip('\r')
        if not target_field_idx:
          print(line, file=fout)
        else:
          fields = line.split('\t')
          if len(fields[target_field_idx].strip()) > 0:
            print(line, file=fout)
          else:
            fields[target_field_idx] = missing_efftime[0]
            print('\t'.join(fields),file=fout)
            replacements += 1
      # EOF
      if replacements > 0: print('Performed %d replacements for empty effectiveTime fields in [%s]' % (replacements, outfile_fnam))
    for f in [fin,fout]: f.close() # close files
    return

  opt = optparse.OptionParser()
  opt.add_option('--rf2',action='store',dest='rf2')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==3):
    print('Usage: set_missing_efftime <yyyymmdd> <input-rf2-rootdir> <output-rf2-rootdir>'); sys.exit(1)
  missing_efftime = [ args[0] ]
  transformer = snomed_g_lib_rf2.TransformRf2(args[1],args[2])
  transformer.walk_files(rf2_file_callback)
# end set_missing_efftime

#------------------------------------------------------------------------------|
#        compare_concept_sets <rf2-1-folder> <rf2-2-folder>                    |
#                                                                              |
# Purpose: Compare sets of concepts in key RF2 files, given 2 RF2 folders      |
#------------------------------------------------------------------------------|

def compare_concept_sets(arglist):

  def rf2_file_callback(file1_path, file2_path, filetype):

    def find_concept_set(target_attributes, in_filename_path):
        result = set()
        fin = io.open(in_filename_path,'r',encoding='utf-8') # open old file
        raw_header = fin.readline()
        if raw_header: # not at EOF (some files may be empty)
            header = raw_header.rstrip('\n').rstrip('\r') # header line MUST exist
            fields = header.split('\t') # tab-sep
            fields_d = { nm: idx for idx,nm in enumerate(fields) }
            while True:
                rawline = fin.readline()
                if not rawline: break
                line = rawline.rstrip('\n').rstrip('\r')
                fields = line.split('\t')
                for attribute in target_attributes:
                    sctid = fields[fields_d[attribute]]
                    result.add(sctid)
        fin.close() # close files
        return result

    def show_diffs_in_keys(diffs,display_message):
      if len(diffs)>0:
        print((display_message+': %d') % len(diffs))
        #for idx,x in enumerate(diffs): print('%4d. [%s]' % (idx+1,x))
        #print()

    # determine target attributes based on filetype
    if filetype=='concept': attribute_list = ['id']
    elif filetype=='description': attribute_list = ['conceptId']
    elif filetype in ['relationship','statedrelationship']: attribute_list = ['sourceId','destinationId']
    else: raise ValueError('compare_concept_sets -- filetype: [%s]' % filetype)
    print('Comparing concepts of type [%s]\nFile1:[%s]\nFile2:[%s]' % (filetype, file1_path, file2_path))
    # determine sets of concepts from file1 and file2
    k1 = find_concept_set(attribute_list, file1_path)
    k2 = find_concept_set(attribute_list, file2_path)
    # compare
    if k1 == k2:
        print('IDENTICAL (%d concepts)' % len(k1))
    else:
      print('Concept sets do not match')
      show_diffs_in_keys(list(k1-k2),'Keys in file1 that are not in file2')
      show_diffs_in_keys(list(k2-k1),'Keys in file2 that are not in file1')
    return

  # compare_concept_sets:
  opt = optparse.OptionParser()
  opts, args = opt.parse_args(arglist)
  if not (len(args)==2):
    print('Usage: compare_concept_sets <rf2-1-rootdir> <rf2-2-rootdir>'); sys.exit(1)
  comparer = snomed_g_lib_rf2.CompareRf2s(args[0],args[1])
  comparer.walk_files(rf2_file_callback)
# end compare_concept_sets

#------------------------------------------------------------------------------|
#        extract_concept_sets <rf2-folder>                                     |
#                                                                              |
# Purpose: Extract sets of concepts from key RF2 files, create concept.txt, etc|
#------------------------------------------------------------------------------|

def extract_concept_sets(arglist):

  def rf2_file_callback(file_path, filetype):

    def find_concept_set(target_attributes, in_filename_path):
        result = set()
        fin = io.open(in_filename_path,'r',encoding='utf-8') # open old file
        raw_header = fin.readline()
        if raw_header: # not at EOF (some files may be empty)
            header = raw_header.rstrip('\n').rstrip('\r') # header line MUST exist
            fields = header.split('\t') # tab-sep
            fields_d = { nm: idx for idx,nm in enumerate(fields) }
            while True:
                rawline = fin.readline()
                if not rawline: break
                line = rawline.rstrip('\n').rstrip('\r')
                fields = line.split('\t')
                for attribute in target_attributes:
                    sctid = fields[fields_d[attribute]]
                    result.add(sctid)
        fin.close() # close files
        return result

    # determine target attributes based on filetype
    if filetype=='concept': attribute_list = ['id']
    elif filetype=='description': attribute_list = ['conceptId']
    elif filetype in ['relationship','statedrelationship']: attribute_list = ['sourceId','destinationId']
    else: raise ValueError('compare_concept_sets -- filetype: [%s]' % filetype)
    print('Extracting concept set from [%s]\nFile:[%s]' % (filetype, file_path))
    # determine sets of concepts from file1 and file2
    k1 = find_concept_set(attribute_list, file_path)
    with open(filetype+'.txt','w') as fout:
        for x in k1: print(x, file=fout)
    return

  # extract_concept_sets:
  opt = optparse.OptionParser()
  opts, args = opt.parse_args(arglist)
  if not (len(args)==1):
    print('Usage: extract_concept_sets <rf2-rootdir>'); sys.exit(1)
  walker = snomed_g_lib_rf2.WalkRf2(args[0])
  walker.walk_files(rf2_file_callback)
# end extract_concept_sets

#------------------------------------------------------------------------------|
#                 full_to_snapshot <in-rf2-file> <out-rf2-file>                |
#                                                                              |
# Purpose: Copy the highest effectiveTime record for each id ==> snapshot      |
#          (drops the non-current rows for each id, the historical-only rows). |
#------------------------------------------------------------------------------|

def full_to_snapshot(arglist):
  opt = optparse.OptionParser()
  opt.add_option('--verbose',action='store_true',dest='verbose')
  opt.add_option('--release',action='store_true',dest='release')
  opts, args = opt.parse_args(arglist)
  if not (len(args)==2): print('Usage: full_to_snapshot <input-rf2-file> <output-rf2-file>'); sys.exit(1)
  fin_fnam, fout_fnam = args

  # --release special processing
  if opts.release:
    transformer = snomed_g_lib_rf2.TransformRf2(fin_fnam, fout_fnam)
    transformer.full_to_snapshot()
    return

  # Pass 1 -- determine the highest effectiveTime for each 'id'
  fieldsep = '\t' # tab-separated fields in RF2 files
  effTime_d = {} # track most current effectiveTime for each id
  id_index, effTime_index = None, None # field numbers of 'id' and 'effectiveTime', when determined
  with io.open(fin_fnam, 'r', encoding='utf-8') as fin:
    fieldnames = chomp(fin.readline()).split('\t') # assume header line exists
    id_index, effTime_index = [fieldnames.index(x) for x in ['id', 'effectiveTime']] # field numbers now known
    while True:
      rawline = fin.readline()
      if not rawline: break # EOF
      fields = chomp(rawline).split(fieldsep)
      id, effTime = [fields[x] for x in [id_index, effTime_index]] # track id, effectiveTime
      if id not in effTime_d or effTime > effTime_d[id]:
        effTime_d[id] = effTime # max effTime ==> most current known definition for id
  # Pass #2 - write only highest effectiveTime for each id to output file
  lines_in_full, lines_in_snapshot = 0, 0
  with io.open(fin_fnam, 'r', encoding='utf-8') as fin, \
       io.open(fout_fnam, 'w', encoding='utf-8') as fout:
    header = chomp(fin.readline()) # header line must exist
    print(header, file=fout)
    while True: # we already know id_index, effTime_index
      rawline = fin.readline()
      if not rawline: break # EOF
      line = chomp(rawline)
      lines_in_full += 1
      fields = line.split(fieldsep)
      id, effTime = [fields[x] for x in [id_index, effTime_index]]
      if effTime == effTime_d[id]: # max ==> should be in snapshot, most current definition
        print(line, file=fout)
        lines_in_snapshot += 1
  # end Pass 2
  print('Processed %d lines from FULL, created %d lines in Snapshot' % (lines_in_full, lines_in_snapshot))
  print('Distinct id values: %d' % len(effTime_d.keys()))
# END full_to_snapshot

#----------------------------------------------------------------------------|
#                                MAIN                                        |
#----------------------------------------------------------------------------|

def parse_and_interpret(arglist):
  command_interpreters = [('make_csv',make_csv),('find_rolenames',find_rolenames),('find_rolegroups',find_rolegroups),
                          ('full_to_snapshot',full_to_snapshot),('get_id_active_fsn',get_id_active_fsn),('set_missing_efftime',set_missing_efftime),
                          ('compare_concept_sets',compare_concept_sets),('extract_concept_sets',extract_concept_sets)]
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