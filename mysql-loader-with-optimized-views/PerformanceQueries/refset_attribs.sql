select LOWER(p.term),GROUP_CONCAT(CONCAT('{"name":"',LOWER(pd.term),'","type":"',LOWER(pt.term),'"}') order by attributeOrder)
FROM soa_refset_RefsetDescriptor
JOIN soa_pref pt ON pt.conceptId=attributeType
JOIN soa_pref pd ON pd.conceptId=attributeDescription
JOIN soa_pref p ON p.conceptId=referencedComponentId
WHERE attributeOrder>0
GROUP BY p.term;
