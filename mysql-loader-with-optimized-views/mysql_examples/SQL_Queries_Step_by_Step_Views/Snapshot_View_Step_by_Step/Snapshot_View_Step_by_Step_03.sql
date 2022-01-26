-- Step By Step Development of a Snapshot Views from the Full Table

-- STEP 3: Get the most recent row for a concept with a specified id value.
-- Using the effectiveTimes reported by step 2 in the query allows us to
-- select only the most recent row.

SELECT * FROM full_concept  
    WHERE id = 157000
    AND effectiveTime = '2006-07-31';

-- Run this query and note that it returns the most recent row for the concept 157000

-- Since the most recent effectiveTime is different for each of the three example
-- concepts, repeating this for each of the concepts involves changing both the id
-- and the effectiveTime! Obviously this manual approach of specifying the
-- effectiveTime for each concept is NOT a practical solution! 
--
-- The next step illustrates how steps 2 and 3 can be built into a single query.