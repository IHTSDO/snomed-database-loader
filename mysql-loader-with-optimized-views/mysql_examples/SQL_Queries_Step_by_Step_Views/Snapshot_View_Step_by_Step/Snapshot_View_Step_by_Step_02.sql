-- Step By Step Development of a Snapshot Views from the Full Table

-- STEP 2: Get the most recent effectiveTime for a concept with a specified id value.
SELECT MAX(effectiveTime) FROM full_concept  
    WHERE id = 157000;

-- This provides the most recent effectiveTime for concept 157000
-- You can also rerun the query for the concepts with id 172001,80146002 noting that each of these gives a different result.

-- Make a note of the most recent effectiveTime for each of the identifiers.