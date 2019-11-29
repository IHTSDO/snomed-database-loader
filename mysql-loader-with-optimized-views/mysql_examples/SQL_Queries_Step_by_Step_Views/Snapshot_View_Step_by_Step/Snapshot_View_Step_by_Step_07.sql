-- Step By Step Development of a Snapshot Views from the Full Table

-- STEP 7: Create a Reusable Retrospective Snapshot View
-- The only different between a current (most recent) snapshot and a retrospective
-- snapshot is that the nested query for a retrospective snapshot must specify 
-- a maximum effectiveTime.
-- 
-- In this example the maximum effective time is specified as 2019-01-31

-- First just in case the view is already there DROP it.
DROP VIEW IF EXISTS myretrosnap_concept;
-- Then create the view called mysnap_concept 
--   - The view is defined based on the query from step 5
--   - The id condition in the main query has been removed so the view includes all concepts 
CREATE VIEW myretrosnap_concept AS 
SELECT tbl.* FROM full_concept  tbl
    WHERE tbl.effectiveTime =  (SELECT MAX(sub.effectiveTime)
           FROM full_concept sub
           WHERE sub.id = tbl.id
           AND sub.effectiveTime<='2009-01-31');

-- After the view has been created the following simple query demonstrates that this view
-- returns only the most recent rows for the selected concepts.
SELECT * FROM myretrosnap_concept WHERE id IN (157000,172001,80146002);

-- Run this query and note that it returns the most recent rows PRIOR TO the specified date
-- for the three concepts specified. In particular note that for the concept 172001 the
-- row returned has the date 2002-01-31 because, although the full table contains a more
-- recent row, that row was added in 2009-07-31, which was after the specified snapshot date.

-- NOTE 1: Retrospective snapshot views can be created for all full tables in the release by
--         following exactly the same pattern.
--         Simply replace the occurences of '_concept' with '_[table-name]' 
--         (where [table-name] is the name of the specific table)

-- NOTE 2: If the maximum value for the condition sub.effectiveTime is specified as
--         a reference to a configurable value (e.g. in a configuration table) it
--         is possible to vary the retrospective snapshot date. Resulting in a more
--         flexible solution. This is the approach implemented in the snap1_ and snap2_
--         views created by the example database.