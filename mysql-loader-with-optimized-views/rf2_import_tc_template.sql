
use `snomedct`;
DELIMITER $$


DROP TABLE IF EXISTS `ss_transclose`$$
CREATE TABLE `ss_transclose` (
`subtypeId` BIGINT NOT NULL DEFAULT  0,
`supertypeId` BIGINT NOT NULL DEFAULT  0,
PRIMARY KEY (`subtypeId`,`supertypeId`),
KEY (`supertypeId`,`subtypeId`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/xder_TransitiveClosure_Snapshot_INT_$YYYYMMDD$.txt'
INTO TABLE `ss_transclose`
LINES TERMINATED BY '\n'

(`subtypeId`,`supertypeId`);$$
