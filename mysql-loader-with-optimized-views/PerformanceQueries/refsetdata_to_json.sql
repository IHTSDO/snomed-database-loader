select CONCAT('{"id":"',p.conceptId,'","name":"',replace(replace(LOWER(p.term),' type reference set (foundation metadata concept)',''),' reference set (foundation metadata concept)',''),'","columns":[',CHAR(10),CHAR(9),'{"name":"referencedComponentId","type":"componentId","mutable":"no"}]},') 
from soa_fsn p 
WHERE LOWER(term) regexp ' type reference set|mrcm (domain|attribute range|attribute domain) ref' AND conceptid in (select subtypeId from ss_transclose WHERE supertypeId=900000000000455006);


select CONCAT('{"id":"',p.conceptId,'","name":"',replace(LOWER(p.term),' reference set',''),'","type":"',replace(replace(LOWER(p2.term),' type reference set (foundation metadata concept)',''),' reference set (foundation metadata concept)',''),'","columns":[',CHAR(10),CHAR(9),'{"name":"referencedComponentId","type":"componentId","mutable":"no"}]},') 
	From soa_pref p 
    join ss_transclose t ON t.subtypeid=p.conceptId 
    join soa_fsn p2 on p2.conceptid=t.supertypeid 
	WHERE LOWER(p.term) not regexp ' type reference set' and LOWER(p2.term) regexp ' type reference set|mrcm (domain|attribute range|attribute domain) ref'
    AND p.conceptid in (select subtypeId from ss_transclose WHERE supertypeId=900000000000455006);
