-- Step By Step Development of a Snapshot Views from the Full Table

-- STEP 5: Generalizable version of the query in step 4.
-- 
-- To make the query generalizable, two changes need to be made
--  a) The two references to the full_concept table must be given distinct aliases
--     to allow them to be separately referenced. In this example:
--       - the outer reference has the alias:  tbl
--       - the nested reference has the alias: sub
--  b) The WHERE clause in the nested query must now test for
--     the id of the concept in the main and nested queries being
--     equal (rather than referring to a specific value)
--
-- Because the query is now generalizable we can also change the
-- main WHERE clause to refer to any concepts. In this example
-- we return specify the same three concept id values using in 
-- step 1.
--
SELECT tbl.* FROM full_concept  tbl
    WHERE tbl.id IN (157000,172001,80146002)
    AND tbl.effectiveTime =  (SELECT MAX(sub.effectiveTime)
           FROM full_concept sub
           WHERE sub.id = tbl.id);

-- Run this query and note that it returns the most recent rows for 
-- the three concepts specified.
--
-- In the next step this query will be turned into a view that
-- can be reused without requiring repetition of the code shown above
-- each time a snapshot is required.
