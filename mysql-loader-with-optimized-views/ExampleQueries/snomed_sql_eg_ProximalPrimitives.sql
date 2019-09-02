-- SNOMED SQL QUERY EXAMPLE : GET PROXIMAL PRIMITIVE SUPERTYPES OF CONCEPT
-- 
-- Returns the proximal primitives for the concept with Id @concept.

-- NOTE
-- The ss_proximal_primitives table must be created before using this.
-- This is part of the full import process but will not have been created if
-- the transitive closure file build and import was removed from the import script


SET @concept=10675911000119109;

SELECT 'Concept' `type`,conceptId,term 'Proximal Primitive Term' FROM soa_fsn
	WHERE conceptId=@concept
UNION
-- If the concept is primitive returns self
SELECT 'Proximal Primitive=Self' `type`,d.conceptId,d.term 'Proximal Primitive Term' FROM soa_fsn d
	JOIN soa_concept c on c.id=@concept
	WHERE d.conceptId=@concept and c.definitionStatusId=900000000000074008
UNION
-- If the concept is not fully-defined returns the proximal primitives of the concept.
-- If the concept if primitive this part of the query returns no rows
SELECT 'Proximal Primitive' `type`,d.conceptId,d.term FROM ss_proximal_primitives pp
	JOIN soa_fsn d on d.conceptId=pp.supertypeId
    WHERE subtypeId=@concept


