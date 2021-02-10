
TRUNCATE TABLE associationrefset_f;
COPY associationrefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Content/csvFiles/der2_cRefset_AssociationFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE attributevaluerefset_f;
COPY attributevaluerefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Content/csvFiles/der2_cRefset_AttributeValueFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE concept_f;
COPY concept_f '/media/yuebing/new_dev/snomedCT/rf2/Full/Terminology/csvFiles/sct2_Concept_Full_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE description_f;
COPY description_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Terminology/csvFiles/sct2_Description_Full-en_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE relationship_f;
COPY relationship_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Terminology/csvFiles/sct2_Relationship_Full_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';

COPY owlexpressionrefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Terminology/csvFiles/sct2_sRefset_OWLExpressionFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE stated_relationship_f;
COPY stated_relationship_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Terminology/csvFiles/sct2_StatedRelationship_Full_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE textdefinition_f;
COPY textdefinition_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Terminology/csvFiles/sct2_TextDefinition_Full-en_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE simplerefset_f;
COPY simplerefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Content/csvFiles/der2_Refset_SimpleFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE langrefset_f;
COPY langrefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Language/csvFiles/der2_cRefset_LanguageFull-en_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE extendedmaprefset_f;
COPY extendedmaprefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Map/csvFiles/der2_iisssccRefset_ExtendedMapFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE simplemaprefset_f;
COPY simplemaprefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Map/csvFiles/der2_sRefset_SimpleMapFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE refsetdescriptorrefset_f;
COPY refsetdescriptorrefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Metadata/csvFiles/der2_cciRefset_RefsetDescriptorFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE descriptiontyperefset_f;
COPY descriptiontyperefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Metadata/csvFiles/der2_ciRefset_DescriptionTypeFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE mrcmattributedomain_f;
COPY mrcmattributedomain_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Metadata/csvFiles/der2_cissccRefset_MRCMAttributeDomainFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE mrcmmodulescoperefset_f;
COPY mrcmmodulescoperefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Metadata/csvFiles/der2_cRefset_MRCMModuleScopeFull_INT_20200731.csv' CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE ModuleDependencyRefset_f;
COPY ModuleDependencyRefset_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Metadata/csvFiles/der2_ssRefset_ModuleDependencyFull_INT_20200731.csv'  CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';


TRUNCATE TABLE MRCMDomain_f;
COPY MRCMDomain_f FROM '/media/yuebing/new_dev/snomedCT/rf2/Full/Refset/Metadata/csvFiles/der2_sssssssRefset_MRCMDomainFull_INT_20200731.csv'  CSV
DELIMITER ',' HEADER
ENCODING 'UTF8';
