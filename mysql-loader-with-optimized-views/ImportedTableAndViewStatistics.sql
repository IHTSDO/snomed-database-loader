CREATE TABLE IF NOT EXISTS `ss_transclose` (
  `subtypeId` bigint(20) NOT NULL DEFAULT '0',
  `supertypeId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`subtypeId`,`supertypeId`),
  KEY `supertypeId` (`supertypeId`,`subtypeId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

SELECT 'Concept Full View Rows' as 'View',COUNT(id) as 'Count' FROM sct2_concept
UNION 
SELECT 'Concept Snapshot Rows',COUNT(id) FROM soa_concept
UNION 
SELECT 'Concept Snapshot Active Rows',COUNT(id) FROM soa_concept WHERE active=1
UNION
SELECT 'Description Full View Rows',COUNT(id) FROM sct2_description
UNION 
SELECT 'Description Snapshot Rows',COUNT(id) FROM sva_description
UNION 
SELECT 'Description Snapshot Active Rows',COUNT(id) FROM sva_description WHERE active=1
UNION
SELECT 'Relationship Full View Rows',COUNT(id) FROM sct2_relationship
UNION 
SELECT 'Relationship Snapshot Rows',COUNT(id) FROM sva_relationship
UNION 
SELECT 'Relationship Snapshot Active Rows',COUNT(id) FROM sva_relationship WHERE active=1
UNION 
SELECT 'IS A Relationship Snapshot Active Rows',COUNT(id) FROM sva_relationship WHERE active=1 and typeId=116680003
UNION 
SELECT 'Transitive Closure Snapshot Active Rows',COUNT(subTypeId) FROM ss_transclose
UNION
SELECT 'Simple Refset Full View Rows' as 'View',COUNT(id) as 'Count' FROM sct2_refset
UNION 
SELECT 'Simple Refset Snapshot Rows',COUNT(id) FROM soa_refset
UNION 
SELECT 'Simple Refset Snapshot Active Rows',COUNT(id) FROM soa_refset_Language WHERE active=1;

SELECT 'Language Refset Full View Rows' as 'View',refsetId, COUNT(id) as 'Count' FROM sct2_refset GROUP BY refsetId
UNION 
SELECT 'Language Refset Snapshot Rows', refsetId, COUNT(id) FROM soa_refset GROUP BY refsetId
UNION 
SELECT 'Language Refset Snapshot Active Rows',refsetId, COUNT(id) FROM soa_refsetLanguage WHERE active=1 GROUP BY refsetId