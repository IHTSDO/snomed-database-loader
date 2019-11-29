CREATE TABLE IF NOT EXISTS `snap_transclose` (
  `subtypeId` bigint(20) NOT NULL DEFAULT '0',
  `supertypeId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`subtypeId`,`supertypeId`),
  KEY `supertypeId` (`supertypeId`,`subtypeId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

SELECT 'Concept Full View Rows' as 'View',COUNT(id) as 'Count' FROM full_concept
UNION 
SELECT 'Concept Snapshot Rows',COUNT(id) FROM snap_concept
UNION 
SELECT 'Concept Snapshot Active Rows',COUNT(id) FROM snap_concept WHERE active=1
UNION
SELECT 'Description Full View Rows',COUNT(id) FROM full_description
UNION 
SELECT 'Description Snapshot Rows',COUNT(id) FROM snap_description
UNION 
SELECT 'Description Snapshot Active Rows',COUNT(id) FROM snap_description WHERE active=1
UNION
SELECT 'Relationship Full View Rows',COUNT(id) FROM full_relationship
UNION 
SELECT 'Relationship Snapshot Rows',COUNT(id) FROM snap_relationship
UNION 
SELECT 'Relationship Snapshot Active Rows',COUNT(id) FROM snap_relationship WHERE active=1
UNION 
SELECT 'IS A Relationship Snapshot Active Rows',COUNT(id) FROM snap_relationship WHERE active=1 and typeId=116680003
UNION 
SELECT 'Transitive Closure Snapshot Active Rows',COUNT(subTypeId) FROM snap_transclose
UNION
SELECT 'Simple Refset Full View Rows' as 'View',COUNT(id) as 'Count' FROM full_refset_Simple
UNION 
SELECT 'Simple Refset Snapshot Rows',COUNT(id) FROM snap_refset_Simple
UNION 
SELECT 'Simple Refset Snapshot Active Rows',COUNT(id) FROM snap_refset_Simple WHERE active=1;

SELECT 'Language Refset Full View Rows' as 'View',refsetId, COUNT(id) as 'Count' FROM full_refset_Language GROUP BY refsetId
UNION 
SELECT 'Language Refset Snapshot Rows', refsetId, COUNT(id) FROM snap_refset_Language GROUP BY refsetId
UNION 
SELECT 'Language Refset Snapshot Active Rows',refsetId, COUNT(id) FROM snap_refset_Language WHERE active=1 GROUP BY refsetId