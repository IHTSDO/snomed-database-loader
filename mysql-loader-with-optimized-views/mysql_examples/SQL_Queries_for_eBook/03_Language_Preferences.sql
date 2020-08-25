SELECT d.* -- select all columns
	FROM (snap_description d -- from the snapshot description table
		JOIN snap_refset_Language lr ON d.id = lr.referencedComponentId) -- join the snapshot description table (id column) with the snapshot language reference set (referencedComponentId column)
			WHERE d.active = 1 AND lr.active = 1 -- only interested in active rows from these tables
				AND d.conceptId = 80146002 -- provide concept SCTID
				AND d.typeId = 900000000000013009 -- description type is synonym (as opposed to FSN)
				AND lr.refSetId = 900000000000509007 -- specify langauge refset 900000000000509007 (US) or 900000000000508004 (GB) 
				AND lr.acceptabilityId = 900000000000548007; -- specify that we are looking for the preferred synonym 

SELECT d.* -- select all columns
	FROM (snap_description d -- from the snapshot description table
		JOIN snap_refset_Language lr ON d.id = lr.referencedComponentId) -- join the snapshot description table (id column) with the snapshot language reference set (referencedComponentId column)
			WHERE d.active = 1 AND lr.active = 1 -- only interested in active rows from these tables
				AND d.conceptId = 80146002 -- provide concept SCTID
				AND d.typeId = 900000000000013009 -- description type is synonym (as opposed to FSN)
				AND lr.refSetId = 900000000000508004 -- specify langauge refset 900000000000509007 (US) or 900000000000508004 (GB) 
				AND lr.acceptabilityId = 900000000000548007; -- specify that we are looking for the preferred synonym