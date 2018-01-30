-- This is the sample indexing script. The indexing should based on the local implementation requirements.

CREATE INDEX description_conceptid_idx ON snomedct.description_f
  USING btree (conceptid COLLATE pg_catalog."default");
CREATE INDEX textdefinition_conceptid_idx ON snomedct.textdefinition_f
  USING btree (conceptid);
CREATE INDEX relationship_f_idx ON snomedct.relationship_f
  USING btree (sourceid, destinationid);
CREATE INDEX stated_relationship_f_idx ON snomedct.stated_relationship_f
  USING btree (sourceid, destinationid);
CREATE INDEX langrefset_referencedcomponentid_idx ON snomedct.langrefset_f
  USING btree (referencedcomponentid);
CREATE INDEX associationrefset_f_idx ON snomedct.associationrefset_f
  USING btree (referencedcomponentid, targetcomponentid);
CREATE INDEX attributevaluerefset_f_idx ON snomedct.attributevaluerefset_f
  USING btree (referencedcomponentid, valueid);
CREATE INDEX simplerefset_referencedcomponentid_idx ON snomedct.simplerefset_f
  USING btree (referencedcomponentid);
CREATE INDEX complexmaprefset_referencedcomponentid_idx ON snomedct.complexmaprefset_f
  USING btree (referencedcomponentid);
CREATE INDEX extendedmaprefset_referencedcomponentid_idx ON snomedct.extendedmaprefset_f
  USING btree (referencedcomponentid);