'''
Module:  snomed_g_lib_rf2.py
Author:  Jay Pedersen, University of Nebraska Medical Center (UNMC), July 2016
Purpose: Define utility classes for processing RF2 format files,
         which are the SNOMED CT release format.
'''

from __future__ import print_function
import os, re, glob, io
import snomedct_constants


def chomp(s): # remove line ending.  <LF> or <CR><LF>
    return s.rstrip('\n').rstrip('\r')


class Rf2_Folders:
  def __init__(self, base_directory, release_type, rel_config='Relationship', language_code='en', language_name='Language'):
    # release_type must be 'snapshot' or 'full' or 'delta'
    # base_directory MUST be the directory which holds the 'Terminlogy' and 'Refset' directories
    global snomedct_terminology_dir, relationship_config,release_format, config_file_suffix
    if rel_config not in ['Relationship','StatedRelationship']:
      raise ValueError('rel_config invalid [%s} -- must be Relationship or StatedRelationship' % rel_config)
    supported_language_codes = ['en','en-us', 'en-GB', 'en-US']
    if language_code not in supported_language_codes:
      raise ValueError('language_code invalid [%s] -- supported list is %s' % (language_code, str(supported_language_codes)))
    self.language_code = language_code
    supported_language_names = ['Language','USEnglish']
    if language_name not in supported_language_names:
      raise ValueError('language_name invalid [%s] -- supported list is %s' % (language_name, str(supported_language_names)))
    self.language_name = language_name
    self.pathsep = '/'
    self.release_type = release_type
    # base_directory must contain Terminology directory
    self.base_dir = base_directory.rstrip(self.pathsep).strip()
    test_dir_name = self.base_dir+self.pathsep+'Terminology'
    if not (os.path.exists(test_dir_name) and os.path.isdir(test_dir_name)):
      raise ValueError('base_directory invalid [%s} -- must contain Terminology directory' % base_directory)
    self.base_dir, self.release_type_root_folder = os.path.split(self.base_dir)
    self.release_type_root_folder_name = self.release_type_root_folder_name(self.release_type) # eg 'Full'
    # eg base_directory /sno/snomedct/nelex/SnomedCT_Release_INT_20170411/SnomedCT_Release_1000004/RF2Release and holds Terminology dir
    # ==> self.base_dir = /sno/snomedct/nelex/SnomedCT_Release_INT_20170411/SnomedCT_Release_1000004
    # ==> self.release_type_root_folder = RF2Release
    # ==> self.release_type_root_folder_name = Full
    if self.release_type_root_folder_name == '<unknown>':
      raise ValueError('Rf2_Files initialization failed -- release_type [%s] invalid' % release_type)
    self.snomedct_terminology_dir = self.base_dir + self.pathsep + self.release_type_root_folder + self.pathsep + 'Terminology' + self.pathsep
    self.snomedct_refset_dir      = self.base_dir + self.pathsep + self.release_type_root_folder + self.pathsep + 'Refset' + self.pathsep
    self.release_format = self.release_type_root_folder_name # Snapshot/Delta/Full
    # determine name of Concept file, in Terminology dir, sct_Concept_<release-format>_<release-center>_<release-date>.txt
    concept_wildcard = self.snomedct_terminology_dir + 'sct2_Concept_*_*.txt'
    fn_start_pos = len(self.snomedct_terminology_dir)
    concept_fn = None # needs to exist outside of try block
    try:
      concept_fn = [x for x in glob.glob(self.snomedct_terminology_dir+'sct2_Concept_*')][0][fn_start_pos:]
    except:
      print(self.snomedct_terminology_dir)
      raise ValueError('*** Cant find/open concept file [%s] ***' % concept_fn)
    if len(concept_fn) == fn_start_pos:
      print(self.snomedct_terminology_dir)
      raise ValueError('*** Cant find/open concept file [%s] ***' % concept_fn)
    concept_fn_regex = 'sct2_Concept_'+self.release_type_root_folder_name+'_'+r'([^_]+)_([^\.]+)\.txt'
    m = re.match(concept_fn_regex, concept_fn)
    if not m:
      raise ValueError('Cant parse RF2 Concept filename -- [%s]' % concept_fn)
    # extract information from Concept file name -- eg sct2_Concept_Snapshot_US1000124_20160301.txt
    self.release_center_str = m.group(1) # eg: US1000124
    self.release_date_str = m.group(2)   # eg: 20160301
    self.config_file_suffix = '%s_%s' % (self.release_center_str, self.release_date_str)
    self.relationship_config = rel_config # 'Relationship' or 'StatedRelationship' later

  def release_type_root_folder_name(self, release_type): # 'Full'/'Snapshot'/'Delta'
    return 'Full' if release_type=='full' else 'Snapshot' if release_type=='snapshot' else 'Delta' if release_type=='delta' else '<unknown>'
  def compute_terminology_dir(self, view): # view in ['Snapshot','Full','Delta']
    return self.base_dir + self.pathsep + view + self.pathsep + 'Terminology' + self.pathsep
  def compute_refset_dir(self,  view):
    return self.base_dir + self.pathsep + view + self.pathsep + 'Refset' + self.pathsep

  # GETTERS
  def get_terminology_dir(self): return self.snomedct_terminology_dir
  def get_refset_dir(self): return self.snomedct_refset_dir
  def get_release_date(self): return self.release_date_str
  def get_release_center(self): return self.release_center_str
  def get_release_type(self): return self.release_type
  def get_release_type_root_folder_name(self): return self.release_type_root_folder_name
  def get_base_dir(self): return self.base_dir

  def rf2_file_path(self, element, view=None):  # NOTE: case-insensitve, 'concept'/'Concept'/'CONCept' are all okay
    release_format = self.release_format if not view else view # eg: specify view='Snapshot', when processing 'Delta'
    terminology_dir = self.snomedct_terminology_dir if not view else self.compute_terminology_dir(view)
    refset_dir = self.snomedct_refset_dir if not view else self.compute_refset_dir(view)
    elem = element.lower()
    if elem=='relationship':  path = terminology_dir+"sct2_%s_%s_%s.txt"    % (self.relationship_config,release_format,self.config_file_suffix)
    elif elem=='concept':     path = terminology_dir+"sct2_%s_%s_%s.txt"    % ('Concept',release_format,self.config_file_suffix)
    elif elem=='description': # eg. sct2_Description_Full-en_INT_20160131.txt
      path = terminology_dir+"sct2_%s_%s-%s_%s.txt" % ('Description',release_format,self.language_code,self.config_file_suffix)
    elif elem=='language': # eg. Refset/Language/der2_cRefset_LanguageFull-en_INT_20160131.txt
      path = refset_dir+"Language"+self.pathsep+"der2_cRefset_%s%s-%s_%s.txt" % (self.language_name,release_format,self.language_code,self.config_file_suffix)
    elif elem=='association_refset': path = refset_dir+"Content"+self.pathsep+"der2_cRefset_AssociationReference%s_%s.txt" % (release_format,self.config_file_suffix)
    else:
      raise ValueError('element:%s to snomed_lib.rf2_file_path' % element)
    return path

class Rf2_Attributes_per_File:
  def __init__(self):
    self.csv_fields = {}
    self.renamed_fields = {} # relative to equivalent RF2 field names
    self.computed_fields = {}
    self.graph_fields = {}
    self.rf2_fields = {} # IMPORTANT -- attributes listed in exact same order as in RF2 file itself
    self.quoted_in_csv_fields = {} # 'history' and 'FSN' and 'term'
    self.external_fields = {}

    # CONCEPT
    self.csv_fields['concept'] =            '''id,effectiveTime,active,moduleId,definitionStatusId,FSN,history'''.split(',')
    self.rf2_fields['concept'] =            '''id,effectiveTime,active,moduleId,definitionStatusId'''.split(',')
    self.graph_fields['concept'] = '''nodetype,id,effectiveTime,active,moduleId,definitionStatusId,sctid,FSN,history'''.split(',')
    self.renamed_fields['concept'] = {} # None, but want empty dictionary for processing ease
    self.computed_fields['concept'] = ['nodetype','sctid','history'] # 'sctid' same as 'id', NOT in csv file, CYPHER creates it
    self.external_fields['concept'] = ['FSN'] # NOT part of SNOMED CT concept definition, one of the descriptions associated with the concept
    self.quoted_in_csv_fields['concept'] = ['history','FSN']

    # DESCRIPTION
    self.csv_fields['description'] =            '''id,sctid,active,typeId,moduleId,descriptionType,id128bit,term,effectiveTime,acceptabilityId,refsetId,caseSignificanceId,languageCode,history'''.split(',')
    self.rf2_fields['description'] =            '''id,effectiveTime,active,moduleId,conceptId,languageCode,typeId,term,caseSignificanceId'''.split(',')
    self.graph_fields['description'] = '''nodetype,id,sctid,active,typeId,moduleId,descriptionType,id128bit,term,effectiveTime,acceptabilityId,refsetId,caseSignificanceId,languageCode,history'''.split(',')
    self.renamed_fields['description'] = { 'sctid' : 'conceptId' }
    self.computed_fields['description'] = ['nodetype','descriptionType','history']
    self.external_fields['description'] = ['acceptabilityId','refsetId','id128bit']
    self.quoted_in_csv_fields['description'] = ['history','term','descriptionType']
    # fields not in RF2 for description, but needed in CSV: descriptionType (compute from acceptabilityId),id128bit(language id value),acceptabilityId (language),refsetId (language)
    self.rf2_fields['language']    = '''id,effectiveTime,active,moduleId,refsetId,referencedComponentId,acceptabilityId'''.split(',')

    # ISA
    self.csv_fields['isa_rel'] =     '''id,effectiveTime,active,moduleId,sourceId,destinationId,relationshipGroup,typeId,characteristicTypeId,history'''.split(',')
    self.rf2_fields['isa_rel'] =     '''id,effectiveTime,active,moduleId,sourceId,destinationId,relationshipGroup,typeId,characteristicTypeId,modifierId'''.split(',')
    self.graph_fields['isa_rel'] =   '''id,effectiveTime,active,moduleId,sourceId,destinationId,relationshipGroup,typeId,characteristicTypeId,history'''.split(',')
    self.renamed_fields['isa_rel'] = {}
    self.computed_fields['isa_rel'] = ['history']
    self.external_fields['isa_rel'] = []
    self.quoted_in_csv_fields['isa_rel'] = ['history']

    # DEFINING-RELATIONSHIPS
    self.csv_fields['defining_rel'] =   '''id,effectiveTime,active,moduleId,sctid,destinationId,rolegroup,typeId,characteristicTypeId,modifierId,history'''.split(',')
    self.rf2_fields['defining_rel'] =   '''id,effectiveTime,active,moduleId,sourceId,destinationId,relationshipGroup,typeId,characteristicTypeId,modifierId'''.split(',')
    self.graph_fields['defining_rel'] = '''id,effectiveTime,active,moduleId,sctid,destinationId,rolegroup,typeId,characteristicTypeId,modifierId,history'''.split(',')
    self.renamed_fields['defining_rel'] = { 'sctid' : 'sourceId', 'rolegroup' : 'relationshipGroup' }
    self.computed_fields['defining_rel'] = ['history']
    self.external_fields['defining_rel'] = ['destinationId'] # not really in the edge, HACKed in by neo4j code, endNode(r).id as destinationId
    self.quoted_in_csv_fields['defining_rel'] = ['history']

    # ASSOCIATION REFSET
    self.csv_fields['association_refset'] =   '''id,effectiveTime,active,moduleId,refsetId,referencedComponentId,targetComponentId,association,history'''.split(',')
    self.rf2_fields['association_refset'] =   '''id,effectiveTime,active,moduleId,refsetId,referencedComponentId,targetComponentId'''.split(',')
    self.graph_fields['association_refset'] = '''id,effectiveTime,active,moduleId,refsetId,referencedComponentId,targetComponentId,association,history'''.split(',')
    self.renamed_fields['association_refset'] = { }
    self.computed_fields['association_refset'] = ['history','association'] # association='SAME AS', etc
    self.external_fields['association_refset'] = []
    self.quoted_in_csv_fields['association_refset'] = ['history']

class Process_Rf2_Release_File: # Delta or Snapshot or Full

  def __init__(self, filename):
    self.filename = filename
    self.f = io.open(self.filename, 'r', encoding='utf-8')
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

  def return_to_BOF(self):
    try:    self.f.seek(0) # back to beginning of file, can re-read
    except: self.f = open(self.filename) # file already closed
    return

# ------------------------------------------------------------------------------------
# Routine: process_concept_file()
# Input:   snomed concept file -- sct2_Concept_<suffix>
# Concept: call callback when for each active concept passing module-id checks
# Note:    generic, the callback routine has no default -- must be supplied
# Note: if used with "Full" file, will returns every line separately
# ------------------------------------------------------------------------------------

def process_concept_file(callback_rtn, require_active=True):

  def filter_callback_rtn(fields, fields_d):
    global concept_module_ids, require_active
    modid  = int(fields[ fields_d['moduleId'] ]) # TODO - want to treat as string
    active = fields[ fields_d['active'] ]
    return (not require_active or active=='1') and modid in concept_module_ids # TODO: check require_active usage

  fn = snomedct_terminology_dir+"sct2_Concept_%s_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

# ------------------------------------------------------------------------------------
# Routine: process_description_file()
# Input:   snomed description file -- sct2_Description_<suffix>
# Concept: callback when an active description passing module-id checks is encountered
# ------------------------------------------------------------------------------------

def process_description_file(callback_rtn, target=None, require_active=True):

  def filter_callback_rtn(fields, fields_d):
    global concept_module_ids
    # fields are [id,effectiveTime,active,moduleId,conceptId,languageCode,typeId,term,caseSignificanceId]
    modid  = int(fields[ fields_d['moduleId'] ]) # TODO -- want to treat as string
    active = fields[ fields_d['active'] ]
    typeId = fields[ fields_d['typeId'] ]
    result = False
    if (not require_active or active=='1') and modid in concept_module_ids:
      if target=='FSN': result = typeId == snomedct_constants.SNOMEDCT_TYPEID_FSN # FSN
      else:             result = True
    return result

  # Note: what of clean_str on "term"?
  fn = snomedct_terminology_dir+"sct2_Description_%s-en_%s.txt" % (release,config_file_suffix)
  file_reader = Process_Rf2_Release_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

# ------------------------------------------------------------------------------------
# Routine: process_relationship_file_DRs/ISA()
# Input:   snomed relationships file -- sct2_[Stated]Relationship_<suffix>
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
      active   = fields[ rkeys['active'] ]
      typeId   = fields[ rkeys['typeId'] ]
      if (not require_active or active=='1') and typeId != snomedct_constants.SNOMEDCT_TYPEID_ISA:  # NOT ISA ==> defining-rel
        callback_rtn(int(typeId), fields, rkeys) # TODO - want to send typeId as string
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
      active   = fields[ rkeys['active'] ]
      typeId   = fields[ rkeys['typeId'] ]
      if (not require_active or active=='1') and typeId == snomedct_constants.SNOMEDCT_TYPEID_ISA:  # ISA
        callback_rtn(fields, rkeys)
  f.close()
  return

# ------------------------------------------------------------------------------------
# Routine: process_language_file()
# Input:   snomed language file -- der2_cRefset_Language<suffix>
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
      active   = fields[ lkeys['active'] ]
      modid    = int(fields[ lkeys['moduleId'] ]) # TODO - want to treat as string
      refsetId = fields[ lkeys['refsetId'] ]
      if (not require_active or active=='1') and modid in concept_module_ids and refsetId == snomedct_constants.SNOMEDCT_REFSETID_USA: # US
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

#------------------------------------------------------------------------------------|
#                            FULL format processing (history)                        |
#------------------------------------------------------------------------------------|

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
    modid  = int(fields[ fields_d['moduleId'] ]) # TODO - want to treat as string
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
    modid  = int(fields[ fields_d['moduleId'] ]) # TODO - want to treat as string
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
    modid  = int(fields[ fields_d['moduleId'] ]) # TODO - want to treat as string
    typeId = fields[ fields_d['typeId'] ]
    if target==None:    result = modid in concept_module_ids
    elif target=='FSN': result = modid in concept_module_ids and typeId == snomedct_constants.SNOMEDCT_TYPEID_FSN # FSN
    else:               raise ValueError('Invalid target in process_full_description_file <<%s>>' % str(target))
    return result

  dir = output_dir if sorted else snomedct_terminology_dir # sorted file in output_dir
  fn = dir + "sct2_Description_%s-en_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Full_Format_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

def filter_callback_relationship(fields, fields_d, target):
  typeId   = fields[ fields_d['typeId'] ]
  if target==None:    result = True # target from process_full_relationship context
  elif target=='DR':  result = typeId != snomedct_constants.SNOMEDCT_TYPEID_ISA # NOT ISA ==> Defining rel
  elif target=='ISA': result = typeId == snomedct_constants.SNOMEDCT_TYPEID_ISA # ISA
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
    modid  = int(fields[ fields_d['moduleId'] ]) # TODO - want to treat as string
    refsetId = fields[ fields_d['refsetId'] ]
    return (modid in concept_module_ids  and refsetId == snomedct_constants.SNOMEDCT_REFSETID_USA) # US

  dir = output_dir if sorted else snomedct_refset_dir # sorted file in output_dir
  fn = dir + "der2_cRefset_Language%s-en_%s.txt" % (release_format,config_file_suffix)
  file_reader = Process_Full_Format_File(fn)
  file_reader.process_file(callback_rtn, filter_callback_rtn)
  return

class TransformRf2:

    def __init__(self, rf2_in_folder_name, rf2_out_folder_name): # constructor
        self.rf2_in_folder_name = rf2_in_folder_name
        self.pathsep = '/'
        # see if base_directory contains Terminology directory, if so, that is the root_folder_name
        self.in_base_dir = rf2_in_folder_name.rstrip(self.pathsep)
        test_dir_name = self.in_base_dir+self.pathsep+'Terminology'
        if not (os.path.exists(test_dir_name) and os.path.isdir(test_dir_name)):
          raise ValueError('base_directory invalid [%s} -- must contain Terminology directory' % base_directory)
        self.rf2_out_folder_name = rf2_out_folder_name.rstrip(self.pathsep)
        self.out_base_dir = rf2_out_folder_name.rstrip(self.pathsep)

    def walk_files(self, callback_rtn):
        pathsep = self.pathsep
        rf2_in_prefix  = self.in_base_dir+pathsep
        rf2_out_prefix = self.out_base_dir+pathsep
        for (in_dirpath, subdirs, in_filenames) in os.walk(self.in_base_dir):
            out_dirpath = rf2_out_prefix + in_dirpath[len(rf2_in_prefix):]
            os.makedirs(out_dirpath)
            for in_filename in in_filenames:
                in_filename_path = in_dirpath+pathsep+in_filename
                out_filename_path = out_dirpath+pathsep+in_filename
                callback_rtn(in_filename_path,out_filename_path)
            # end for in_filename
        # for in_dirpath in os.walk

    def full_to_snapshot(self): # walk input directory structure, translate to output

        # NOTE: UNSURE IF THIS WORKS CORRECTLY, JGP 20170420.  It bases its decision on
        #       the key of a row based only on the 'id' property.  That works for concepts
        #       and relationships.  Does it work for descriptions and language files?

        def convert_full_to_snapshot(key_field_list, fin_fnam, fout_fnam):
            # Pass 1 -- determine highest effectiveTime for each primary_key (eg: 'id')
            fieldsep = '\t'  # tab-separated fields in RF2 files
            effTime_d = {}  # track most current effectiveTime for each id
            id_index, effTime_index = None, None  # field numbers of 'id' and 'effectiveTime', when determined
            with io.open(fin_fnam, 'r', encoding='utf-8') as fin:
                fieldnames = chomp(fin.readline()).split('\t')  # assume header line exists
                id_index, effTime_index = [fieldnames.index(x)
                                           for x in ['id', 'effectiveTime']]  # field numbers now known
                while True:
                    rawline = fin.readline()
                    if not rawline: break  # EOF
                    fields = chomp(rawline).split(fieldsep)
                    id, effTime = [fields[x] for x in [id_index, effTime_index]]  # track id, effectiveTime
                    if id not in effTime_d or effTime > effTime_d[id]:
                        effTime_d[id] = effTime  # max effTime ==> most current known definition for id
            # Pass #2 - write only highest effectiveTime for each id to output file
            lines_in_full, lines_in_snapshot = 0, 0
            with io.open(fin_fnam, 'r', encoding='utf-8') as fin, \
                    io.open(fout_fnam, 'w', encoding='utf-8') as fout:
                header = chomp(fin.readline())  # header line must exist
                print(header, file=fout)
                while True:  # we already know id_index, effTime_index
                    rawline = fin.readline()
                    if not rawline: break  # EOF
                    line = chomp(rawline)
                    lines_in_full += 1
                    fields = line.split(fieldsep)
                    id, effTime = [fields[x] for x in [id_index, effTime_index]]
                    if effTime == effTime_d[id]:  # max ==> should be in snapshot, most current definition
                        print(line, file=fout)
                        lines_in_snapshot += 1
            # end Pass 2
            print('Processed %d lines from FULL, created %d lines in Snapshot' % (lines_in_full, lines_in_snapshot))
            print('Distinct id values: %d' % len(effTime_d.keys()))
        # end convert_full_to_snapshot

        def copy_file(in_filename, out_filename):
            fin, fout = io.open(in_filename,'r',encoding='utf8'),io.open(out_filename,'w',encoding='utf8')
            while True:
                rawline = fin.readline()
                if not rawline: break # EOF
                line = rawline.rstrip('\n').rstrip('\r')
                print(line, file=fout)
            for f in [fin,fout]: f.close()

        # full_to_snapshot:
        pathsep = self.pathsep
        rf2_in_prefix  = self.in_base_dir+pathsep
        rf2_out_prefix = self.out_base_dir+pathsep
        for (in_dirpath, subdirs, in_filenames) in os.walk(self.in_base_dir):
            out_dirpath = rf2_out_prefix + in_dirpath[len(rf2_in_prefix):]
            os.makedirs(out_dirpath)
            for in_filename in in_filenames:
                in_filename_path = in_dirpath+pathsep+in_filename
                out_filename_path = out_dirpath+pathsep+in_filename
                if in_dirpath.endswith('/Refset/Language'):
                    print('Process LANGUAGE file [%s]' % (in_filename_path,))
                    convert_full_to_snapshot(['id'], in_filename_path, out_filename_path)
                elif in_dirpath.endswith('/Terminology'):
                    # Check for Concept/Relationship/StatedRelationship/Description
                    if in_filename.startswith('sct2_Concept_'):
                        print('Process CONCEPT file [%s]' % in_filename)
                        convert_full_to_snapshot(['id'], in_filename_path, out_filename_path)
                    elif in_filename.startswith('sct2_Description_'):
                        print('Process DESCRIPTION file [%s]' % in_filename)
                        convert_full_to_snapshot(['id'], in_filename_path, out_filename_path)
                    elif any(in_filename.startswith(x)
                             for x in ['sct2_Relationship_', 'sct2_StatedRelationship_']):
                        print('Process RELATIONSHIP file [%s]' % in_filename)
                        convert_full_to_snapshot(['id'], in_filename_path, out_filename_path)
                    elif in_filename.startswith('sct2_TextDefinition_'):
                        print('Process TextDefinition file [%s]' % in_filename)
                        convert_full_to_snapshot(['id'], in_filename_path, out_filename_path)
                    else:
                        print('COPY miscellaneous file [%s]' % (in_filename_path,))
                        copy_file(in_filename_path, out_filename_path)
                elif in_dirpath.endswith('/Refset/Map'):
                    print('COPY map file [%s]' % (in_filename_path,))
                    copy_file(in_filename_path, out_filename_path)
                else:
                    print('COPY miscellaneous file [%s]' % (in_filename_path,))
                    copy_file(in_filename_path, out_filename_path)
            # end for in_filename
        # for in_dirpath in os.walk

    def process_files(self, mapped_NELEX_codes_set, NELEX_to_LOINC_map):

        def process_RF2_file(target_attributes, in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map):
            translations = 0
            fin = open(in_filename_path) # open old file
            fout = open(out_filename_path, 'w') # create new file
            raw_header = fin.readline()
            if raw_header: # not EOF (some files may be empty)
                header = raw_header.rstrip('\n').rstrip('\r') # header line MUST exist
                print(header, file=fout) # header line in new file
                fields = header.split('\t') # tab-sep
                fields_d = { nm: idx for idx,nm in enumerate(fields) }
                while True:
                    rawline = fin.readline()
                    if not rawline: break
                    line = rawline.rstrip('\n').rstrip('\r')
                    if len(target_attributes)==0:
                        print(line, file=fout) # simply copying file
                    else:
                        fields = line.split('\t')
                        for attribute in target_attributes:
                            sctid = fields[fields_d[attribute]]
                            if sctid in mapped_NELEX_codes_set: fields[fields_d[attribute]] = NELEX_to_LOINC_map[sctid]; translations += 1
                        print('\t'.join(fields),file=fout) # new codes
            for f in [fin,fout]: f.close() # close files
            print('Translations: %d for [%s]' % (translations, out_filename_path))
            return

        # Start of process_files()
        # Step. Step through the input RF2 folders, create matching folders for the output RF2.
        print('[[[ Walking RF2 input folders ]]]')
        rf2_in_prefix = self.rf2_in_folder_name
        rf2_out_prefix = self.rf2_out_folder_name
        print('in prefix: [%s]' % rf2_in_prefix)
        out_map_folder_name = None
        sno_suffix = None # eg Snapshot_INT_20170331
        for (in_dirpath, subdirs, in_filenames) in os.walk(self.rf2_in_folder_name):
            if not in_dirpath.startswith(rf2_in_prefix): print('Cant process directory path [%s]' % dirpath); sys.exit(1)
            out_dirpath = rf2_out_prefix + in_dirpath[len(rf2_in_prefix):]
            os.makedirs(out_dirpath)
            for in_filename in in_filenames:
                in_filename_path = in_dirpath+pathsep+in_filename
                out_filename_path = out_dirpath+pathsep+in_filename
                if in_dirpath.endswith('\Refset\Language'):
                    print('Process LANGUAGE file [%s]' % (in_filename_path,))
                    process_RF2_file(['referencedComponentId'], in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map)
                elif in_dirpath.endswith('\Terminology'):
                    # Check for Concept/Relationship/StatedRelationship/Description
                    if in_filename.startswith('sct2_Concept_'):
                        print('Process CONCEPT file [%s]' % in_filename)
                        process_RF2_file(['id'], in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map)
                        # Snag the suffix (for use in map file)
                        sno_suffix = in_filename[len('sct2_Concept_'):-4]
                    elif in_filename.startswith('sct2_Description_'):
                        print('Process DESCRIPTION file [%s]' % in_filename)
                        process_RF2_file(['conceptId'], in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map)
                    elif in_filename.startswith('sct2_Relationship_') or in_filename.startswith('sct2_StatedRelationship_'):
                        print('Process RELATIONSHIP file [%s]' % in_filename)
                        process_RF2_file(['sourceId','destinationId'], in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map)
                    else:
                        print('COPY miscellaneous file [%s]' % (in_filename_path,))
                        process_RF2_file([], in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map)
                elif in_dirpath.endswith('\Refset\Map'):
                    print('Dropping MAP file [%s]' % in_filename_path)
                    out_map_folder_name = out_dirpath
                else:
                    print('COPY miscellaneous file [%s]' % (in_filename_path,))
                    process_RF2_file([], in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map)
# end class TransformRf2:

class CompareRf2s:

    def __init__(self, rf2_one_folder_name, rf2_two_folder_name): # constructor, must contain "Terminology" subfolder
        self.pathsep = '\\'
        self.rf2_one_folder_name = rf2_one_folder_name.rstrip(self.pathsep)
        self.rf2_two_folder_name = rf2_two_folder_name.rstrip(self.pathsep)
        # specified folder must contain the "Terminology" subfolder (should also have "Refset")
        self.one_base_dir = self.rf2_one_folder_name
        self.two_base_dir = self.rf2_two_folder_name
        for base_dir in [self.one_base_dir, self.two_base_dir]:
            test_dir_name = base_dir+self.pathsep+'Terminology'
            if not (os.path.exists(test_dir_name) and os.path.isdir(test_dir_name)):
                raise ValueError('base_directory invalid [%s} -- must contain Terminology subfolder' % base_dir)

    def walk_files(self, callback_rtn):

        def find_key_files(base_dir):

            def normalize_path(filepath): return filepath.replace('/','\\')

            pathsep = self.pathsep
            result = {}
            for (in_dirpath_raw, subdirs, in_filenames) in os.walk(base_dir):
                in_dirpath = normalize_path(in_dirpath_raw)
                for in_filename in in_filenames:
                    in_filename_path = in_dirpath+pathsep+in_filename
                    # Categorize file, ignore all but Concept, Description, Relationship, Language
                    #if in_dirpath.endswith('\\Refset\\Language'):
                    #    print('Process LANGUAGE file [%s]' % (in_filename_path,))
                    #    process_RF2_file(['referencedComponentId'], in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map)
                    if in_dirpath.endswith('\\Terminology'):
                        # Check for Concept/Relationship/StatedRelationship/Description
                        if in_filename.startswith('sct2_Concept_'):
                            result['concept'] = in_filename_path
                        elif in_filename.startswith('sct2_Description_'):
                            result['description'] = in_filename_path
                        elif in_filename.startswith('sct2_Relationship_'):
                            result['relationship'] = in_filename_path
                        elif in_filename.startswith('sct2_StatedRelationship_'):
                            result['statedrelationship'] = in_filename_path
                # end in_filename loop
            # end in_dirpath loop
            return result
        # end find_key_files

        # walk_files
        pathsep = self.pathsep
        rf2_one_prefix  = self.one_base_dir+pathsep
        rf2_two_prefix = self.two_base_dir+pathsep
        one_files = find_key_files(rf2_one_prefix)
        two_files = find_key_files(rf2_two_prefix)
        one_set = set(one_files.keys())
        two_set = set(two_files.keys())
        in_both = one_set & two_set
        for filetype in in_both:
            callback_rtn(one_files[filetype], two_files[filetype], filetype)
    # end walk_files

# end CompareRF2s

class WalkRf2:

    def __init__(self, rf2_folder_name): # constructor, must contain "Terminology" subfolder
        self.pathsep = '\\'
        self.rf2_folder_name = rf2_folder_name.rstrip(self.pathsep)
        # specified folder must contain the "Terminology" subfolder (should also have "Refset")
        self.base_dir = self.rf2_folder_name
        for base_dir in [self.base_dir]:
            test_dir_name = base_dir+self.pathsep+'Terminology'
            if not (os.path.exists(test_dir_name) and os.path.isdir(test_dir_name)):
                raise ValueError('base_directory invalid [%s} -- must contain Terminology subfolder' % base_dir)

    def walk_files(self, callback_rtn):

        def find_key_files(base_dir):

            def normalize_path(filepath): return filepath.replace('/','\\')

            pathsep = self.pathsep
            result = {}
            for (in_dirpath_raw, subdirs, in_filenames) in os.walk(base_dir):
                in_dirpath = normalize_path(in_dirpath_raw)
                for in_filename in in_filenames:
                    in_filename_path = in_dirpath+pathsep+in_filename
                    # Categorize file, ignore all but Concept, Description, Relationship, Language
                    #if in_dirpath.endswith('\\Refset\\Language'):
                    #    print('Process LANGUAGE file [%s]' % (in_filename_path,))
                    #    process_RF2_file(['referencedComponentId'], in_filename_path, out_filename_path, mapped_NELEX_codes_set, NELEX_to_LOINC_map)
                    if in_dirpath.endswith('\\Terminology'):
                        # Check for Concept/Relationship/StatedRelationship/Description
                        if in_filename.startswith('sct2_Concept_'):
                            result['concept'] = in_filename_path
                        elif in_filename.startswith('sct2_Description_'):
                            result['description'] = in_filename_path
                        elif in_filename.startswith('sct2_Relationship_'):
                            result['relationship'] = in_filename_path
                        elif in_filename.startswith('sct2_StatedRelationship_'):
                            result['statedrelationship'] = in_filename_path
                # end in_filename loop
            # end in_dirpath loop
            return result
        # end find_key_files

        # walk_files
        pathsep = self.pathsep
        rf2_prefix  = self.base_dir+pathsep
        key_files = find_key_files(rf2_prefix)
        for filetype in key_files.keys():
            callback_rtn(key_files[filetype], filetype)
    # end walk_files

# end WalkRF2

# Note: NO MAIN, library module
