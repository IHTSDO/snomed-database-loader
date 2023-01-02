'''
Module:  snomed_g_lib_neo4j.py
Author:  Jay Pedersen, July 2016
Purpose: Define utility classes for accessing NEO4J databases containing SNOMED_G data.
'''

import py2neo, sys

def db_data_prep(v):
  return v if isinstance(v,unicode) else unicode( (str(v) if isinstance(v, int) else v) , "utf8")

class Neo4j_Access:
  def __init__(self, base64pw):
    # NEO4J init
    self.graph_db = py2neo.Graph("bolt://localhost:7687", auth=("neo4j", base64pw))  # 'http://localhost:7474/db/data/transaction/commit'

  def lookup_elements_by_id(self,query_template,query_target_variable,id_field_name,id_list,chunk_size):
    matches = {}
    n = chunk_size
    for chunk in [id_list[idx:idx+n] for idx in range (0, len(id_list), n)]:
      cypher_str = query_template % (str(chunk),query_target_variable) # eg: 'match ... where a.sctid in %s return %s'
      cursor = None
      try:
        cursor = self.graph_db.run(cypher_str)
      except:
        print('DB Failure for [%s]' % cypher_str)
        raise
        sys.exit(1)
      else:
        pass # succeeded
      # end of exception processing
      # List result
      idx = 0
      while cursor.forward():
        idx += 1
        r = cursor.current()[query_target_variable] # variable in CYPHER query
        matches[r[id_field_name]] = { a : r[a] for a in r.keys() } # copy.deepcopy(r) # copy dictionary
      # end of processing result from this chunk
    # end of chunk processing
    return matches

  def make_attribute_map_by_id(self,query_template,query_target_variable,id_field_name,id_list,chunk_size,target_attribute,allow_dup_prefer_active=False):
    matches = {}
    n = chunk_size
    for chunk in [id_list[idx:idx+n] for idx in range (0, len(id_list), n)]:
      cypher_str = query_template % (str(chunk),query_target_variable) # eg: 'match ... where a.sctid in %s return %s'
      cursor = None
      try:
        cursor = self.graph_db.run(cypher_str)
      except:
        print('DB Failure for [%s]' % cypher_str)
        raise
        sys.exit(1)
      else:
        pass # succeeded
      # end of exception processing
      # List result
      idx = 0
      while cursor.forward():
        idx += 1
        r = cursor.current()[query_target_variable] # variable in CYPHER query
        keyvalue = db_data_prep(r[id_field_name])
        if not allow_dup_prefer_active:
          matches[keyvalue] = db_data_prep(r[target_attribute])
        else:
          if keyvalue not in matches: # Prefer active='1'
            matches[keyvalue] = db_data_prep(r[target_attribute])
          elif db_data_prep(r['active'])=='1':
            matches[keyvalue] = db_data_prep(r[target_attribute])
      # end of processing result from this chunk
    # end of chunk processing
    return matches

  def lookup_concepts_for_ids(self, id_list):
    return self.lookup_elements_by_id('match (a:ObjectConcept) where a.sctid in %s return %s',
                                 'a','sctid',id_list,200)
  def lookup_Fsns_for_ids(self, id_list):
    # TODO: cant there be more than one FSN for a particular concept?, where one or more is not active??
    #       ==> assume no more than one FSN with active='1' for a particular concept
    # GOAL: "prefer" active, but "inactive" presumably is not always wrong -- inactivated concept with inactivated FSN may exist??
    return self.make_attribute_map_by_id('''match (a:ObjectConcept) where a.sctid in %s return %s''',
                                         'a', 'id', id_list, 200, 'FSN', True)
  def lookup_descriptions_for_ids(self, id_list): # Description id, NOT sctid
    return self.lookup_elements_by_id('match (a:Description) where a.id in %s return %s',
                                 'a','id',id_list,100)
  def lookup_descriptions_for_sctid(self, sctid): # all descriptions for specific concept
    return self.lookup_elements_by_id('match (o:ObjectConcept)-[r:HAS_DESCRIPTION]->(a:Description) where o.id in %s return %s',
                                      'a','id',[sctid],100)

  def extract_property_names(self, cursor, vbl_name):
    # NOTE: ONE result only, guaranteed by LIMIT 1
    property_names = []
    idx = 0
    while cursor.forward():
      idx += 1
      property_names = cursor.current()[vbl_name]
      # eg: [u'typeId', u'effectiveTime', u'active', ..., u'history']
      print('%d. %s' % (idx, str(property_names)))
      return property_names
    print('*** extract_property_names FAILED -- no result'); sys.exit(1)
    return []

  def execute_cypher(self, cypher_string):
    command_list = [ x.rstrip('\n').rstrip('\r') for x in cypher_string.split('\n') if len(x) > 0]
    succeeded, failed = 0, 0
    for idx,cmd in enumerate(command_list):
      cursor = None
      try:
        cursor = self.graph_db.run(cmd)
      except:
        print('DB Failure for [%s]' % cmd)
        failed += 1
      else:
        succeeded += 1
    # Report statistics
    print('%d commands succeeded' % succeeded)
    if failed>0: print('*** %d commands FAILED ***' % failed); sys.exit(1)
    return cursor

  def lookup_all_concepts(self): # Why?? 7 minutes to read concepts by id values -- 37 seconds to read ALL (with around 426K ids)
    cypher_q = '''MATCH (a:ObjectConcept)'''
    # Query #1 -- determine keys(r)
    vbl_name = 'keys(a)'
    cypher_str = cypher_q + ' return %s LIMIT 1' % vbl_name
    neo4j_cursor = self.execute_cypher(cypher_str)
    field_names = self.extract_property_names(neo4j_cursor,vbl_name)
    # Query #2, return all properties for every matching object
    cypher_str = cypher_q + ' return ' + ','.join('a.%s' % x for x in field_names)
    neo4j_cursor = self.execute_cypher(cypher_str)
    result = {}
    while neo4j_cursor.forward():
      result[neo4j_cursor.current()['a.id']] = { nm: neo4j_cursor.current()['a.%s' % nm] for nm in field_names }
    return result

  def lookup_all_descriptions(self):  # Why? Can be over 1.2 million descriptions for FULL/SNAPSHOT, dont look individually
    cypher_q = '''MATCH (a:Description)'''
    # Query #1 -- determine keys(r)
    vbl_name = 'keys(a)'
    cypher_str = cypher_q + ' return %s LIMIT 1' % vbl_name
    neo4j_cursor = self.execute_cypher(cypher_str)
    field_names = self.extract_property_names(neo4j_cursor,vbl_name)
    # Query #2, return all properties for every matching object
    cypher_str = cypher_q + ' return ' + ','.join('a.%s' % x for x in field_names)
    neo4j_cursor = self.execute_cypher(cypher_str)
    result = {}
    while neo4j_cursor.forward():
      result[neo4j_cursor.current()['a.id']] = { nm: neo4j_cursor.current()['a.%s' % nm] for nm in field_names }
    return result

  def lookup_all_isa_rels(self):  # Why? No indexes on edges, if large lookup, this is fastest way to get all info
    cypher_q = '''MATCH (a:ObjectConcept)-[r:ISA]->(b:ObjectConcept)'''
    # Query #1 -- determine keys(r)
    vbl_name = 'keys(r)'
    cypher_str = cypher_q + ' return %s LIMIT 1' % vbl_name
    neo4j_cursor = self.execute_cypher(cypher_str)
    field_names = self.extract_property_names(neo4j_cursor,vbl_name)
    # Query #2, return all properties for every matching object
    cypher_str = cypher_q + ' return ' + ','.join('r.%s' % x for x in field_names)
    neo4j_cursor = self.execute_cypher(cypher_str)
    result = {}
    while neo4j_cursor.forward():
      result[neo4j_cursor.current()['r.id']] = { nm: neo4j_cursor.current()['r.%s' % nm] for nm in field_names }
    return result

  def lookup_all_defining_rels(self): # Why? No indexes on edges, if large lookup, this is fastest way to get all info
    cypher_q = '''MATCH (a:RoleGroup)-[r]->(b:ObjectConcept)'''
    # Query #1 -- determine keys(r)
    vbl_name = 'keys(r)'
    cypher_str = cypher_q + ' return %s LIMIT 1' % vbl_name
    neo4j_cursor = self.execute_cypher(cypher_str)
    field_names = self.extract_property_names(neo4j_cursor,vbl_name) # wont include destinationId
    # Query #2, return all properties for every matching object
    cypher_str = cypher_q + ' return ' + ','.join('r.%s' % x for x in field_names) + ',endNode(r).id as destinationId'
    neo4j_cursor = self.execute_cypher(cypher_str)
    result = {}
    while neo4j_cursor.forward():
      result[neo4j_cursor.current()['r.id']] = { nm: neo4j_cursor.current()['r.%s' % nm] for nm in field_names }
      result[neo4j_cursor.current()['r.id']]['destinationId'] = neo4j_cursor.current()['destinationId']
    return result

  def lookup_isa_rels_for_ids(self, id_list):  # SLOOOOOOOOOOOOOOOOOOOOOOOOOOOOW
    return self.lookup_elements_by_id('match (a:ObjectConcept)-[r:ISA]->(b:ObjectConcept) where r.id in %s return %s',
                                      'r','id',id_list,100)
  def lookup_defining_rels_for_ids(self, id_list): # SLOOOOOOOOOOOOOOOOOOOOOOOOOOOOW
    return self.lookup_elements_by_id('match (a:RoleGroup)-[r]->(b:ObjectConcept) where r.id in %s return %s',
                                      'r','id',id_list,100)
  def lookup_rolegroups_for_sctid(self, sctid):
    return self.lookup_elements_by_id('match (o:ObjectConcept)-[r]->(a:RoleGroup) where a.sctid in %s return %s',
                                 'a','rolegroup',[sctid],100)
