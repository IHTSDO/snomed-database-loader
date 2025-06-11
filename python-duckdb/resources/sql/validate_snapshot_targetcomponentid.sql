select *
from associationrefset_s
where targetcomponentid not in (
    select id from concept_s
    union
    select id from description_s
);