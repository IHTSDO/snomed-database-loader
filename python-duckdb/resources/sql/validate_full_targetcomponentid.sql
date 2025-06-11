select *
from associationrefset_f
where targetcomponentid not in (
    select id from concept_f
    union
    select id from description_f
);