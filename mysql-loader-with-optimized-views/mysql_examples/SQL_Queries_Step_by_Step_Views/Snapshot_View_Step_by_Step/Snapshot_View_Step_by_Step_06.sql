-- Step By Step Development of a Snapshot Views from the Full Table

-- STEP 6: Create a Reusable Snapshot View Using the Query from Step 5
-- 

-- First just in case the view is already there DROP it.
DROP VIEW IF EXISTS mysnap_concept;
-- Then create the view called mysnap_concept 
--   - The view is defined based on the query from step 5
--   - The id condition in the main query has been removed so the view includes all concepts 
CREATE VIEW mysnap_concept AS 
SELECT tbl.* FROM full_concept  tbl
    WHERE tbl.effectiveTime =  (SELECT MAX(sub.effectiveTime)
           FROM full_concept sub
           WHERE sub.id = tbl.id);

-- After the view has been created the following simple query demonstrates that this view
-- returns only the most recent rows for the selected concepts.
SELECT * FROM mysnap_concept WHERE id IN (157000,172001,80146002);

-- Run this query and note that it returns the most recent rows for 
-- the three concepts specified.

-- NOTE: Snapshot views can be created for all full tables in the release by
--       following exactly the same pattern.
--       Simply replace the occurences of '_concept' with '_[table-name]' 
--       (where [table-name] is the name of the specific table)

-- In the next step we consider how to create a similar view for retrospective snapshots
-- that is snapshot views as they were at a specified past date.
