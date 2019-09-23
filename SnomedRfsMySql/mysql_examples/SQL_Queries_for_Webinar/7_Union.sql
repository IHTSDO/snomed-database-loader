-- Expression Constraint 
-- < 10790700 | Operative procedure on digestive system |  
-- AND < 363687006 | Endoscopic procedure |

-- Show preferred term for 107907001
SELECT conceptId, term 
FROM snap_pref
WHERE conceptId = 107907001;

-- Show preferred term for 363687006
SELECT conceptId, term 
FROM snap_pref
WHERE conceptId = 363687006;

-- Show subtypes of both concepts
SELECT tc.subtypeId, pt.term
FROM snap_transclose as tc,snap_transclose as tc2, snap_pref as pt
-- < 10790700 | Operative procedure on digestive system |
WHERE tc.supertypeId = 107907001 
AND pt.conceptId = tc.subtypeId
-- < 363687006 | Endoscopic procedure |
AND tc2.supertypeId = 363687006 
AND pt.conceptId = tc2.subtypeId
ORDER BY pt.term;

