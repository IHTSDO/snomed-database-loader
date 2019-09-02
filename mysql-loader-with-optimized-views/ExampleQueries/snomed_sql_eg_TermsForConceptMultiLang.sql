-- SNOMED SQL QUERY EXAMPLE : FIND TERMS FOR A CONCEPT
-- 
-- Find the Terms associated with a concept with id “19829001” 
-- in different languages.
-- Note the output will go to two different result tabs in MySQL Workbench

SET @conceptId=80146002;

CALL setLanguage('en-US');
select 'FSN en-US' `type and lang`,`term` from `soa_fsn` where `conceptid`=@conceptId
UNION
select 'SYN en-US (preferred)',`term` from `soa_pref` where `conceptid`=@conceptId
UNION
select 'Synonyms en-US',`term` from `soa_syn` where `conceptid`=@conceptId;
CALL setLanguage('en-GB');
select 'FSN en-GB' `type and lang`,`term` from `soa_fsn` where `conceptid`=@conceptId
UNION
select 'SYN en-GB (preferred)',`term` from `soa_pref` where `conceptid`=@conceptId
UNION
select 'SYN en-GB (acceptable)',`term` from `soa_syn` where `conceptid`=@conceptId;
CALL setLanguage('en-US');