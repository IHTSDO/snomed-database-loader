-- Step By Step Development of a Snapshot Views from the Full Table

-- STEP 4: Combine steps 2 and 3 in a single query.
--
 SELECT * FROM full_concept  
    WHERE id = 157000
    AND effectiveTime =  (SELECT MAX(effectiveTime)
           FROM full_concept
           WHERE id = 157000);

-- Run this query and note that it returns the most recent row for the concept 157000
--
-- This query is still NOT generalizable to provide a snapshot view of all concepts.
-- It requires the same id to be specified in the main query and the nested query.
-- 
-- The next step revises this query to provide a generalizable solution.
