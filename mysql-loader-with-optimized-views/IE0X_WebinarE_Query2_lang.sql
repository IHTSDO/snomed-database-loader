CALL setLanguage('en-US');
select 'FSN en-US' `type and lang`,`term` from `soa_fsn` where `conceptid`=80146002
UNION
select 'Synonyms en-US',`term` from `soa_synall` where `conceptid`=80146002;
CALL setLanguage('en-GB');
select 'FSN en-GB' `type and lang`,`term` from `soa_fsn` where `conceptid`=80146002
UNION
select 'Synonyms en-GB',`term` from `soa_synall` where `conceptid`=80146002;
CALL setLanguage('en-US');