select *
from associationrefset_d
where targetcomponentid not in (
    select id from concept_d
    union
    select id from description_d
);