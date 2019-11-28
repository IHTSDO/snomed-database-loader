-- Step By Step Development of Description Composite Views - Introduction

-- This folder contains a series of queries that illustrate the steps in developing
-- useful composite views of descriptions from existing snapshot views of concepts, 
-- descriptions and language reference sets.
--
-- Each step explained and illustrated in a separate SQL script file containing
-- notes accompanied by an SQL query that can be run in the SNOMED CT Example Database.
-- 
-- All the scripts have the same name followed by a number indicating the order of the steps.
--
-- The idea of these files is to illustrate each of the key points in this logical process.
-- If you are only interested in using the database for access to the terminology this
-- is not for you. However, if you are interested in understanding how composite views can be
-- derived from a snapshot release tables you may find this helpful.
--

-- All versions of all synonyms for concept 80146002
SELECT
   *
FROM
   full_description
WHERE
   conceptId = 80146002 and typeId = 900000000000013009;

-- All versions of synonym with descriptionId 132967011
SELECT
    *
   FROM
       full_description tbl
   WHERE
       conceptId = 80146002 and typeId = 900000000000013009  
        and id=132967011;

-- Most recent effectiveTime for synonym with descriptionId 132967011
SELECT
	MAX(sub.effectiveTime)
           FROM
               full_description sub
           WHERE
               sub.id = 132967011;
               
-- Row with most recent effectiveTime for synonym with descriptionId 33388017
SELECT
    *
   FROM
       full_description tbl
   WHERE
       conceptId = 80146002 and typeId = 900000000000013009  
        and id=132967011 and effectiveTime = 20170731;

-- Nested identification of most recent row for every synonym of concept 80146002
SELECT
    *
   FROM
       full_description tbl
   WHERE
       conceptId = 80146002 and typeId = 900000000000013009  
        AND effectiveTime = 
        (SELECT
               MAX(sub.effectiveTime)
           FROM
               full_description sub
           WHERE
               sub.id = tbl.id);
			

-- SNAPSHOT of active synonyms for concept 80146002
SELECT
    *
   FROM
       snap_description d
   WHERE
       d.conceptId = 80146002 AND d.typeId = 900000000000013009 
	   AND d.active = 1;

-- Preferred synonym for concept 80146002
SELECT
    *
   FROM
       snap_description d
   JOIN 
	   snap_refset_language rs ON d.id = rs.referencedComponentId
   WHERE
       d.conceptId = 80146002
       AND d.active = 1
       AND d.typeId = 900000000000013009 -- Synonym
--      AND rs.refsetId = 900000000000509007 -- US Language Refset
       AND rs.refsetId = 900000000000508004 -- GB Language Refset
       AND rs.active = 1
	   AND rs.acceptabilityId = 900000000000548007; -- Preferred Acceptability