select * from full_concept tbl
	where tbl.effectiveTime > '20190131' and tbl.effectiveTime <= '20190731'
union
select * from full_concept tbl
	where tbl.effectiveTime = (select max(sub.effectiveTime) from full_concept sub 
								where sub.id = tbl.id and sub.effectiveTime<='20190131')
    and tbl.id IN (select id from full_concept 
					where effectiveTime > '20190131' and effectiveTime <= '20190731')
order by id;