-- SNOMED SQL QUERY EXAMPLE : LIST CONCEPTS SUBSUMED BY TWO CONCEPTS
--
-- Get Concepts that are subtypes of 2 different concepts
-- 
-- < 10790700 | Operative procedure on digestive system |  
-- AND < 363687006 | Endoscopic procedure |

-- Change the conceptids here to repeat with other concepts

SET @conceptid1=107907001;
SET @conceptid2=363687006;


-- Show preferred term for @conceptid1
SELECT conceptId, term 
FROM sva_pref
WHERE conceptId = @conceptid1;

-- Show preferred term for @conceptid2
SELECT conceptId, term 
FROM sva_pref
WHERE conceptId = @conceptid2;

-- Show subtypes of both concepts
SELECT tc.subtypeId, pt.term
FROM ss_transclose as tc,ss_transclose as tc2, sva_pref as pt
-- < 10790700 | Operative procedure on digestive system |
WHERE tc.supertypeId = @conceptid1 
AND pt.conceptId = tc.subtypeId
-- < @conceptid2 | Endoscopic procedure |
AND tc2.supertypeId = @conceptid2 
AND pt.conceptId = tc2.subtypeId
ORDER BY pt.term;

