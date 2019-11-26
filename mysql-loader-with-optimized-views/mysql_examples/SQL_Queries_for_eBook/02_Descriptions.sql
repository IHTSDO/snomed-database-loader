select * from snap_description -- only interested in descriptions from the current release (snapshot)
where conceptId=80146002 -- provide concept SCTID
	and active=1; -- only looking for active descriptions