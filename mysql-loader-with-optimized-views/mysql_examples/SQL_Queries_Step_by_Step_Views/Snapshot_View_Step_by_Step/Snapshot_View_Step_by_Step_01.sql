-- Step By Step Development of a Snapshot Views from the Full Table

-- STEP 1: Get all versions of concepts with specified id values.
--
-- In the example we look at three concepts with the following id values 172001,157000,80146002
-- Because we are looking for all versions the query looks at the full_concept table

SELECT * FROM full_concept  
    WHERE id IN (157000,172001,80146002) 
    ORDER BY id,effectiveTime;

-- Run this query and note that the following points:
-- 1) Five rows are returned although only three distict id values were specified
-- 2) Two of the concept id values are present in two rows with different effectiveTime values
-- 3) All of the concepts were initially added with an effectiveTime of 2002-01-31 (the first SNOMED CT release)
-- 4) Two of the concepts were subsequently updated with later effectiveTime values
--    - One update changed the active value (inactivating the concept)
--    - The other update changed the definitionStatusId (the concept became "define" rather than "primitive")
--
-- You can also adapt this query by changing the concept id values selected to look at other concepts.
-- However, to provide simple example the following steps all use the three concept ids shown here.
