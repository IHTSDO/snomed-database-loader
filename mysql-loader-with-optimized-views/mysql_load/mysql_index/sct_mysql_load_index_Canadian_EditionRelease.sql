

-- ===========================================
-- Reindex Tables
-- ===========================================


-- The SQL Script Generate a Snapshot View Transitive Closure Table 
-- that links all concepts to all their Supertype Ancestors

DELIMITER ;

USE `$DBNAME`;

DELIMITER ;;

-- Create a procedure that create builds Transitive Closure Views
-- A procedure is created and called because a procedure can determine
-- where the snap_transclose table contains any rows.
-- If not the views are not created.

DROP PROCEDURE IF EXISTS CreateTransCloseViews;;
CREATE PROCEDURE CreateTransCloseViews()
CRCV:BEGIN

SET @tccount=(SELECT count(supertypeId) FROM `snap_transclose` LIMIT 10);

-- IF THE Transitive Closure Table includes less than 10 rows exit procedure
IF @tccount<10 THEN
	SELECT CONCAT('** Transitive Closure Table contains ',@tccount,' rows **');
	SELECT '** Transitive Closure Views Not Created! **';
	LEAVE CRCV;
END IF;

SET @ppcount=(SELECT count(supertypeId) FROM `snap_proximal_primitives` LIMIT 1);
IF @ppcount=0 THEN
-- Create proximal primitive supertypes table
	DROP TABLE IF EXISTS `snap_supertypes_defprim`;
	DROP TABLE IF EXISTS `snap_supertypes_primprim`;
	DROP TABLE IF EXISTS `snap_supertypes_prim_nonprox`;

	CREATE TEMPORARY TABLE `snap_supertypes_defprim` (
	`subtypeId` bigint NOT NULL DEFAULT '0',
	`supertypeId` bigint NOT NULL DEFAULT '0',
	PRIMARY KEY (`subtypeId`,`supertypeId`),
	KEY `p_rev` (`supertypeId`,`subtypeId`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

	CREATE TEMPORARY TABLE `snap_supertypes_primprim` (
	`subtypeId` bigint NOT NULL DEFAULT '0',
	`supertypeId` bigint NOT NULL DEFAULT '0',
	PRIMARY KEY (`subtypeId`,`supertypeId`),
	KEY `pp_rev` (`supertypeId`,`subtypeId`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

	CREATE TEMPORARY TABLE `snap_supertypes_prim_nonprox` (
	`subtypeId` bigint NOT NULL DEFAULT '0',
	`supertypeId` bigint NOT NULL DEFAULT '0',
	PRIMARY KEY (`subtypeId`,`supertypeId`),
	KEY `p_rev` (`supertypeId`,`subtypeId`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- Create table with Primitive Supertypes only and ignore rows where subtypes is primitive
	INSERT INTO `snap_supertypes_defprim`
	SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
		FROM `snap_transclose` `tc`
		JOIN `snap_concept` `c` on `c`.`id`=`tc`.`supertypeId` 
			AND `c`.`definitionStatusId`=900000000000074008
		JOIN `snap_concept` `c2` on `c2`.`id`=`tc`.`subtypeId`
			AND `c2`.`definitionStatusId`<>900000000000074008
	WHERE `tc`.`supertypeId`<>138875005;

-- For all concepts that are primitive supertypes get their primitive supertypes
	INSERT INTO `snap_supertypes_primprim`
	SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
		FROM snap_transclose `tc`
		JOIN `snap_concept` `c` on `c`.`id`=`tc`.`supertypeId` 
			AND `c`.`definitionStatusId`=900000000000074008
		WHERE `tc`.`subtypeId` IN (SELECT `supertypeId`
				FROM `snap_supertypes_defprim`)
			AND `tc`.`supertypeId`<>138875005;

-- Identify the non-promixal relationships
	INSERT INTO `snap_supertypes_prim_nonprox`
	SELECT DISTINCT `tc`.`subtypeId`,`tp`.`supertypeId`
		FROM `snap_supertypes_defprim` `tc`
		JOIN `snap_supertypes_primprim` `tp` ON `tp`.`subtypeId`=`tc`.`supertypeId`;

-- Insert the proximal primitives into the table
	INSERT INTO `snap_proximal_primitives` 
	SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
		FROM `snap_supertypes_defprim` `tc`
		WHERE NOT EXISTS(SELECT * FROM `snap_supertypes_prim_nonprox` `tp`
		WHERE `tp`.`subtypeId`=`tc`.`subtypeId` 
			AND `tp`.`supertypeId`=`tc`.`supertypeId`);
END IF;

SELECT Now() `--`,"Create Transitive Closure and Proximal Primitive Views" '--';

-- CREATE TRANSITIVE CLOSURE VIEWS

DROP VIEW IF EXISTS `snap_tc_descendant_fsn`;

CREATE VIEW `snap_tc_descendant_fsn` AS
(SELECT `r`.`subtypeId` `id`,`d`.`term` `term`,`r`.`supertypeId` `conceptId`
	FROM  `snap_transclose` `r`
	JOIN `snap_fsn` `d` ON (`r`.`subtypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_tc_descendant_pref`;

CREATE VIEW `snap_tc_descendant_pref` AS
(SELECT `r`.`subtypeId` `id`,`d`.`term` `term`,`r`.`supertypeId` `conceptId`
	FROM  `snap_transclose` `r`
	JOIN `snap_pref` `d` ON (`r`.`subtypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_tc_ancestor_fsn`;

CREATE VIEW `snap_tc_ancestor_fsn` AS
(SELECT `r`.`supertypeId` `id`,`d`.`term` `term`,`r`.`subtypeId` `conceptId`
	FROM  `snap_transclose` `r`
	JOIN `snap_fsn` `d` ON (`r`.`supertypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_tc_ancestor_pref`;

CREATE VIEW `snap_tc_ancestor_pref` AS
(SELECT `r`.`supertypeId` `id`,`d`.`term` `term`,`r`.`subtypeId` `conceptId`
	FROM  `snap_transclose` `r`
JOIN `snap_pref` `d` ON (`r`.`supertypeId` = `d`.`conceptId`));

-- PROXIMAL PRIMITIVE VIEWS

DROP VIEW IF EXISTS `snap_pp_child_fsn`;

CREATE VIEW `snap_pp_child_fsn` AS
(SELECT `r`.`subtypeId` `id`,`d`.`term` `term`,`r`.`supertypeId` `conceptId`
	FROM  `snap_proximal_primitives` `r`
	JOIN `snap_fsn` `d` ON (`r`.`subtypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_pp_child_pref`;

CREATE VIEW `snap_pp_child_pref` AS
(SELECT `r`.`subtypeId` `id`,`d`.`term` `term`,`r`.`supertypeId` `conceptId`
	FROM  `snap_proximal_primitives` `r`
	JOIN `snap_pref` `d` ON (`r`.`subtypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_pp_parent_fsn`;

CREATE VIEW `snap_pp_parent_fsn` AS
(SELECT `r`.`supertypeId` `id`,`d`.`term` `term`,`r`.`subtypeId` `conceptId`
	FROM  `snap_proximal_primitives` `r`
	JOIN `snap_fsn` `d` ON (`r`.`supertypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_pp_parent_pref`;

CREATE VIEW `snap_pp_parent_pref` AS
(SELECT `r`.`supertypeId` `id`,`d`.`term` `term`,`r`.`subtypeId` `conceptId`
	FROM  `snap_proximal_primitives` `r`
JOIN `snap_pref` `d` ON (`r`.`supertypeId` = `d`.`conceptId`));

END;;

DELIMITER ;

CALL CreateTransCloseViews();
DROP PROCEDURE IF EXISTS  CreateTransCloseViews;-- CONTAINS eclQuery and the Older version eclSimple
USE `$DBNAME`;

CREATE TABLE IF NOT EXISTS `config_resultsets` (
  `setId` varchar(12) NOT NULL,
  `conceptId` bigint(20) NOT NULL,
  PRIMARY KEY (`conceptId`,`setId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DELIMITER ;;
DROP PROCEDURE IF EXISTS `eclQuery`;;
CREATE PROCEDURE `eclQuery`(`p_ecl` text)
proc:BEGIN
	 CALL eclQuerySelect(`p_ecl`,'fsn');
END;;

DROP PROCEDURE IF EXISTS `eclQuerySelect`;;
CREATE PROCEDURE `eclQuerySelect`(`p_ecl` text,`style` text)
proc:BEGIN
	CALL eclQueryGetIds(`p_ecl`,'temp~get');
	CASE `style`
		WHEN 'exp' THEN
			SELECT CONCAT(`t`.`conceptId`,'|',`t`.`term`,'|') FROM `config_resultsets` `r` JOIN `snap_pref` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'expfsn' THEN
			SELECT CONCAT(`t`.`conceptId`,'|',`t`.`term`,'|') FROM `config_resultsets` `r` JOIN `snap_fsn` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'pref' THEN
			SELECT `t`.`conceptId`,`t`.`term` FROM `config_resultsets` `r` JOIN `snap_pref` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'fsn' THEN
			SELECT `t`.`conceptId`,`t`.`term` FROM `config_resultsets` `r` JOIN `snap_fsn` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'allsyn' THEN
			SELECT `t`.`conceptId`,`t`.`term` FROM `config_resultsets` `r` JOIN `snap_allsyn` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'count' THEN
			SELECT count(`conceptId`) FROM `config_resultsets` WHERE `setId`='temp~get';
		ELSE
			SELECT `conceptId` FROM `config_resultsets` WHERE `setId`='temp~get';
		END CASE;
END;;

DROP PROCEDURE IF EXISTS `eclQueryCount`;;
CREATE PROCEDURE `eclQueryCount`(`p_ecl` text,OUT `p_count` INT)
proc:BEGIN
	CALL eclQueryGetIds(`p_ecl`,'temp~count');
	SET `p_count`=(SELECT count(`conceptId`) From `config_resultsets` WHERE `setId`="temp~count");
END;;

DROP PROCEDURE IF EXISTS `eclQueryGetIds`;;
CREATE PROCEDURE `eclQueryGetIds`(`p_ecl` text, `p_setId` text)
--
-- Specify the ECL and a setId to be used store the resulting list of conceptIds.
-- This adds rows for matching items a two column table called config_resultsets
-- First column has the p_setId (allowing multiple sets to be saved with different keys)
-- Second column is the conceptId of a matching concept.
-- The data is retained in config_resultsets for use outside the procedure.
-- E.g. SELECT conceptId FROM config_resultsets WHERE setId="someset"
-- Length of setId is limited to 12 characters (after removing and prefixing symbols +,-,?,!)
-- Added feature is that starting the key with (+) adds matches to the set, minus (-) removes matches from the table.
-- Also a question mark or exclamation mark (? or !) before the key outputs diagnostics on the constraint
-- With no specified set the procedure will output the id and preferred term (in this case the result is not saved)
--
proc:BEGIN
	DECLARE `v_ecltrim` text DEFAULT '';
	DECLARE `v_eclClause` text DEFAULT '';
	DECLARE `v_focus` text DEFAULT '';
	DECLARE `v_refine` text DEFAULT '';
	DECLARE `v_item` text DEFAULT '';
	DECLARE `v_clauseNum` int DEFAULT 1;
	DECLARE `v_testNum` int DEFAULT 1;
	DECLARE `v_refineCount` int DEFAULT 1;
	DECLARE `v_clauseCount` int DEFAULT 1;
	DECLARE `v_clauseRule`  char(1) DEFAULT '';
	DECLARE `v_valSymbol` char(4) DEFAULT '';
	DECLARE `v_attSymbol` char(4) DEFAULT '';
	DECLARE `v_attId` BIGINT DEFAULT 0;
	DECLARE `v_valId` BIGINT DEFAULT 0;
	DECLARE `v_valTestIn` char(6) DEFAULT 'IN';
	DECLARE `v_value` text DEFAULT '';
	DECLARE `v_attrib` text DEFAULT '';
	DECLARE `v_prevSetRule` char(1) DEFAULT '';
	DECLARE `v_id` int DEFAULT 0;
	DECLARE `v_ClauseTable` text DEFAULT '';
	DECLARE `v_InSource` text DEFAULT '';
	DECLARE `v_targetTable` text DEFAULT '';
	DECLARE `v_diagnostic` BOOLEAN DEFAULT FALSE;
	DECLARE `done` BOOLEAN DEFAULT FALSE;
	DECLARE specialty CONDITION FOR SQLSTATE '45000';
	DECLARE `msg` text;

	DECLARE `curClause` CURSOR FOR SELECT `clauseNum`,max(`clauseRule`), count(`id`) FROM `tmpEcl` GROUP BY `clauseNum` ORDER BY `clauseNum`;
	DECLARE `curRefine` CURSOR FOR SELECT `id`,`testNum`, `attId`,`attSymbol`,`valId`,`valSymbol`,`valTestIn` FROM `tmpEcl` WHERE `clauseNum`=`v_clauseNum` ORDER BY `testNum`;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET `done` := TRUE;
	-- SELECT CONCAT("MODE: ",`p_mode`);
	SET @ver=(SELECT VERSION());
	IF @ver<8 THEN
		SET `msg`='The eclQuery procedure requires MySQL 8.0+. Please use eclSimple() with earlier versions.';
		SELECT `msg`;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = `msg`;
	END IF;

	-- IF p_ecl STARTS WITH ? outputs diagnostics from parsing into tmpEcl table
	IF LEFT(`p_ecl`,1)='?' THEN
			SET `v_diagnostic`=TRUE;
			SET `p_ecl`=TRIM(MID(`p_ecl`,2));
	END IF;

	DROP TABLE IF EXISTS `tmpEcl`;
	CREATE TEMPORARY TABLE `tmpEcl` (
		`id` INT NOT NULL AUTO_INCREMENT,
		`clauseNum` INT NOT NULL DEFAULT 0,
		`testNum` INT NOT NULL DEFAULT 0,
		`clauseRule` CHAR(1) DEFAULT '',
		`attId` BIGINT NOT NULL DEFAULT 0,
		`attSymbol` CHAR(4) NOT NULL DEFAULT '',
		`valId` BIGINT NOT NULL DEFAULT 0,
		`valSymbol` CHAR(4) NOT NULL DEFAULT '',
		`valTestIn` CHAR(6) NOT NULL DEFAULT 'IN',
		`count` BIGINT NOT NULL DEFAULT 0,
		PRIMARY KEY (`id`));

	DROP TABLE IF EXISTS `tmpSourceIds`;
	DROP TABLE IF EXISTS `tmpIds`;
	CREATE TEMPORARY TABLE `tmpIds` (
			`id` bigint NOT NULL DEFAULT '0',
			PRIMARY KEY (`id`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

	DROP TABLE IF EXISTS `ResultTable`;

	-- NESTED REPLACEMENTS DO THE FOLLOWING
	-- 1. Remove text between paired pipes
	-- 2. Replace alternative representations of AND with ',a'
	-- 3. Replace alternative representations of OR with ',o'
	-- 4. Replace alternative representations or MINUS with ',m'
	-- 5. Remove all spaces (this must be done after 2,3,4 as these rely on spaces around words/symbols)
	SET `v_ecltrim`=regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(`p_ecl`,'[|][^|]*[|]',''),' +(AND|[Aa]nd|&+) +',',a'),' +([oO][rR]|\\|+) +',',o'),' +(minus|[Mm]inus|-) +',',m'),' *','');

	-- IF NOT ENCLOSED IN BRACKETS ADD OUTER BRACKETS FOR CONSISTENT SUBSEQUENT PROCESSING
	IF `v_ecltrim` not regexp '^\\(.*\\)$' THEN
		SET `v_ecltrim`=CONCAT('(',`v_ecltrim`,')');
	END IF;

	-- CHECK THAT BRACKETS ARE BALANCED AND NOT MISPLACED
	IF `v_ecltrim` not regexp '^\\([^\\(\\)]*(\\),[aom]?\\([^\\(\\)]*)*\\)$' THEN
		SELECT "ERR: Unbalanced or Misplaced Brackets";
			LEAVE proc;
	END IF;
	-- TRIMMED SYMBOLIC VERSION CREATED AND ALL OK

	-- Loop to extract ECL clauses enclosed in brackets (allows multiply constraint with AND / OR / MINUS)
	getClause: LOOP
			-- Each iteration get the next ECL clause
			SET `v_eclClause`=regexp_substr(`v_ecltrim`,'[aom]?\\([^\\(\\)]*\\),?',1,`v_clauseNum`);
			IF ISNULL(`v_eclClause`) OR `v_clauseNum`>20 THEN
					LEAVE getClause;
			END IF;
			-- Get the rule letter a=and o=or m=minus between this and ECL clause (if any)
			IF `v_eclClause` regexp '^[aom]' THEN 
					SET `v_clauseRule`= LEFT(`v_eclClause`,1);
					-- remove rule letter and leading bracket
					SET `v_eclClause`=MID(`v_eclClause`,3);
			ELSE
					-- Just remove leading bracket
					SET `v_eclClause`=MID(`v_eclClause`,2);
			END IF;
			-- Trim ECL clause to contents of brackets
			SET `v_eclClause`=substring_index(`v_eclClause`,')',1);
			-- Check the ECL clause is processable (no nesting or grouping present in ECL Clause)
			IF `v_eclClause` regexp '\\(' THEN
					SELECT 'ERR: Nesting constraint not supported. Character "(" in an ECL Clause',`v_eclClause`;
					LEAVE proc;
			END IF;
			IF `v_eclClause` regexp ':.*:' THEN
					SELECT 'ERR: Nesting constraint not supported. More than one ":" in an ECL Clause',`v_eclClause`;
					LEAVE proc;
			END IF;
			IF `v_eclClause` regexp '[\\{\\}]' THEN
					SELECT 'ERR: Grouping constraints not supported. Characters "{" or "}" in an ECL Clause',`v_eclClause`;
					LEAVE proc;
			END IF;
			-- If the ECL clause contains a : split the focus and refinement at that point. Otherwise it is just a focus constraint
			IF `v_eclClause` regexp ':' THEN
					SET `v_focus`=substring_index(`v_eclClause`,':',1);
					SET `v_refine`=substring_index(`v_eclClause`,':',-1);
			ELSE
					SET `v_focus`=`v_eclClause`;
					SET `v_refine`='';
			END IF;
			SET `v_testNum`=1;
			-- Get the symbol and id for the focus concept and add this as a record in a temporary ECL table (tmpEcl)
			SET `v_valSymbol`=IFNULL(regexp_substr(`v_focus`,'(\\*|\\^|<[<!]?|>[>!]?)'),'=');
			SET `v_valId`=IFNULL(regexp_substr(`v_focus`,'[1-9][0-9]{5,17}'),0);
			INSERT INTO `tmpEcl` (`clauseNum`,`clauseRule`,`testNum`,`attId`,`attSymbol`,`valId`,`valSymbol`,`valTestIn`) values (`v_clauseNum`,`v_clauseRule`,`v_testNum`,0,'',`v_valId`,`v_valSymbol`,0);
			
			IF `v_refine`!='' THEN
					-- to simplify iteration add a comma before the refinement (this allows simple regexp pattern iteration)
					SET `v_refine`=CONCAT(',',`v_refine`);
					getRefine: LOOP
							-- Iterate through the refinement constraints spliting at the commas
							SET `v_item`=regexp_substr(`v_refine`,',[^,]+',1,`v_testNum`);
							SET `v_testNum`=`v_testNum`+1;
							IF ISNULL(`v_item`) OR `v_testNum`>20 THEN
									-- exit here when no more refinements (or after a maximum number of iterations as an error catcher)
									LEAVE getRefine;
							END IF;
							SET `v_item`=mid(`v_item`,2);
							-- SELECT `v_testNum`,`v_item`;
							SET `v_attrib`=substring_index(`v_item`,'=',1);
							-- Check for negated attribute value != (so ! as last char of v_attrib)
							SET `v_valTestIn`=IF(`v_attrib` regexp '!$',"NOT IN","IN");
							SET `v_value`=substring_index(`v_item`,'=',-1);
							-- SELECT `v_attrib`,`v_value`;
							SET `v_valSymbol`=IFNULL(regexp_substr(`v_value`,'(\\*|\\^|<<?)'),'=');
							SET `v_valId`=IFNULL(regexp_substr(`v_value`,'[1-9][0-9]{5,17}'),0);
							SET `v_attSymbol`=IFNULL(regexp_substr(`v_attrib`,'(\\*\\^|<<?)'),'=');
							SET `v_attId`=IFNULL(regexp_substr(`v_attrib`,'[1-9][0-9]{5,17}'),0);
							-- SELECT `v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`;
							INSERT INTO `tmpEcl` (`clauseNum`,`testNum`,`clauseRule`,`attId`,`attSymbol`,`valId`,`valSymbol`,`valTestIn`) values (`v_clauseNum`,`v_testNum`,`v_clauseRule`,`v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`,`v_valTestIn`);
					END LOOP getRefine;
			END IF;
			SET `v_clauseNum`=`v_clauseNum`+1;
	END LOOP getClause;

	SET `v_clauseCount`=(SELECT max(`clauseNum`) FROM `tmpEcl`);

	OPEN `curClause`;
	SET `done`=FALSE;

	clauseLoop: LOOP
		FETCH `curClause` INTO `v_clauseNum`,`v_clauseRule`,`v_refineCount`;
		IF `done` then
				LEAVE clauseLoop;
		END IF;
		-- SELECT `v_clauseNum`;
		SET `v_ClauseTable`=IF(`v_clauseNum`=1,'ResultTable','tmpClauseIds');
		SET `v_inSource`='';
		OPEN `curRefine`;
		refineLoop: LOOP
			FETCH `curRefine` INTO `v_id`,`v_testNum`,`v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`,`v_valTestIn`;
			IF `done` then
				SET `done`=FALSE;
				CLOSE `curRefine`;
				LEAVE refineLoop;
			END IF;
			IF `v_testNum`=`v_refineCount` THEN
				SET `v_targetTable`=`v_ClauseTable`;
			ELSE
				SET `v_targetTable`=CONCAT('tmpRefineIds_',`v_testNum`);
			END IF;

			SET @dropTable=CONCAT('DROP TABLE IF EXISTS ',`v_targetTable`);
			PREPARE s_dropTable FROM @dropTable;
			EXECUTE s_dropTable;
			DEALLOCATE PREPARE s_dropTable;

			SET @createTable=CONCAT('CREATE TEMPORARY TABLE `',`v_targetTable`,'` LIKE `tmpIds`');
			PREPARE s_createTable FROM @createTable;
			EXECUTE s_createTable;
			DEALLOCATE PREPARE s_createTable;
			SET @insertIds=CONCAT('INSERT IGNORE INTO `',`v_targetTable`,'` (`id`) ');

			IF `v_attId`=0 THEN
					-- Focus concept test
				CASE `v_valSymbol`
						WHEN '=' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `id` FROM `snap_concept` WHERE `id`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `id`',`v_inSource`),''));
						WHEN '^' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `referencedComponentId` FROM `snap_refset_simple` WHERE `refsetId`=',`v_valId`,' AND `active`=1',IF(`v_inSource`!='',CONCAT(' AND `referencedComponentId`',`v_inSource`),''));
						WHEN '<' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `subtypeId`',`v_inSource`),''));
						WHEN '<<' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `subtypeId` FROM `snap_transclose` WHERE (`supertypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005))',IF(`v_inSource`!='',CONCAT(' AND `subtypeId`',`v_inSource`),''));
						WHEN '<!' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `id` FROM `snap_rel_child_fsn` WHERE `conceptId`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `id`',`v_inSource`),''));
						WHEN '>' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `supertypeId` FROM `snap_transclose` WHERE `subtypeId`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `supertypeId`',`v_inSource`),''));
						WHEN '>>' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `supertypeId` FROM `snap_transclose` WHERE (`subtypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005))',IF(`v_inSource`!='',CONCAT(' AND `supertypeId`',`v_inSource`),''));
						WHEN '>!' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `id` FROM `snap_rel_parent_fsn` WHERE `conceptId`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `id`',`v_inSource`),''));
						WHEN '*' THEN
								SET @insertIds=CONCAT(@insertIds,'SELECT `id` FROM `snap_concept` WHERE `active`=1',IF(`v_inSource`!='',CONCAT(' AND `id`',`v_inSource`),''));
						ELSE
								SELECT CONCAT('ERR: Invalid focus concept symbol: ',`v_valSymbol`);
								LEAVE proc;
				END CASE;
			-- Check that the attribute specified is a valid attribute or * for any attribute
			-- Valid attributes are subtypes of 410662002 | Concept model attribute |
			ELSEIF `v_attSymbol`='*' OR `v_attId` IN (SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=410662002) THEN
					-- General Source for Inserting Ids is same for refinements the other settings only add conditions
					SET @insertIds=CONCAT(@insertIds,'SELECT `sourceId` FROM `snap_relationship` WHERE active=1',IF(`v_inSource`!='',CONCAT(' AND `sourceId`',`v_inSource`),''));

					-- ADD CONDITIONS FOR typeId
					CASE `v_attSymbol`
							WHEN '=' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `typeId`=',`v_attId`);
							WHEN '<' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=',`v_attId`,')');
							WHEN '<<' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `subtypeId` FROM `snap_transclose` WHERE (`supertypeId`=',`v_attId`,' or (`subtypeId`=',`v_attId`,' and `supertypeId`=410662002)))');
							WHEN '<!' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `id` FROM `snap_rel_child_fsn` WHERE `conceptId`=',`v_attId`,')');
							WHEN '>' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `supertypeId` FROM `snap_transclose` WHERE `subtypeId`=',`v_attId`,')');
							WHEN '>>' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `supertypeId` FROM `snap_transclose` WHERE (`subtypeId`=',`v_attId`,' or (`subtypeId`=',`v_attId`,' and `supertypeId`=138875005))',')');
							WHEN '>!' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `id` FROM `snap_rel_parent_fsn` WHERE `conceptId`=',`v_attId`,')');
							ELSE
									-- Symbol * implies any attribute type. Other symbols are errors
									IF `v_attSymbol`!='*' THEN
											SELECT CONCAT('ERR: Invalid attribute type symbol: ',`v_attSymbol`);
											LEAVE proc;
									END IF;
					END CASE;
					-- ADD CONDITIONS FOR destinationId

					CASE `v_valSymbol`
							WHEN '=' THEN
									IF `v_valTestIn`='IN' THEN
										SET @insertIds=CONCAT(@insertIds,' AND `destinationId`=',`v_valId`);
									ELSE
										SET @insertIds=CONCAT(@insertIds,' AND `destinationId`!=',`v_valId`);
									END IF;
							WHEN '<' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=',`v_valId`,')');
							WHEN '<<' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `subtypeId` FROM `snap_transclose` WHERE (`supertypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005)))');
							WHEN '<!' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `id` FROM `snap_rel_child_fsn` WHERE `conceptId`=',`v_valId`,')');
							WHEN '>' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `supertypeId` FROM `snap_transclose` WHERE `subtypeId`=',`v_valId`,')');
							WHEN '>>' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `supertypeId` FROM `snap_transclose` WHERE (`subtypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005)))');
							WHEN '>!' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `id` FROM `snap_rel_parent_fsn` WHERE `conceptId`=',`v_valId`,')');
							WHEN '^' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `referencedComponentId` FROM `snap_refset_simple` WHERE `refsetId`=',`v_valId`,' AND `active`=1',')');
							ELSE
									IF `v_valSymbol`!='*' THEN
											-- Symbol * implies any value. Other symbols are errors
											SELECT CONCAT('ERR: Invalid attribute value symbol: ',`v_valSymbol`);
											LEAVE proc;
									END IF;
					END CASE;
			ELSE
					SELECT CONCAT('ERR: Invalid attributeId Specified: ',`v_attid`);
					LEAVE proc;
			END IF;
			PREPARE s_insertIds FROM @insertIds;
			EXECUTE s_insertIds;
			UPDATE `tmpEcl` SET `count`=ROW_COUNT() where `id`=`v_id`;
			DEALLOCATE PREPARE s_insertIds;

			-- v_inSource is for first loop then becomes v_targetTable from previous iteration
			SET `v_inSource`=CONCAT(' IN (SELECT `id` FROM ',`v_targetTable`,')');
		END LOOP refineLoop;
		IF `v_clauseNum`>1 THEN
			CASE `v_clauseRule`
				WHEN 'o' THEN -- OR
					INSERT IGNORE INTO `ResultTable` (`id`) SELECT `id` FROM `tmpClauseIds`;
				WHEN 'a' THEN -- AND
					ALTER TABLE `ResultTable` RENAME TO  `tmpSourceIds` ;
					CREATE TABLE `ResultTable` LIKE `tmpIds`;
					INSERT IGNORE INTO `ResultTable` (`id`) SELECT `c`.`id` FROM `tmpClauseIds` `c` JOIN `tmpSourceIds` `s` ON `s`.`id`=`c`.`id` ;
					DROP TABLE `tmpSourceIds`;
				WHEN 'm' THEN -- MINUS
					ALTER TABLE `ResultTable` RENAME TO  `tmpSourceIds` ;
					CREATE TABLE `ResultTable` LIKE `tmpIds`;
					INSERT IGNORE INTO `ResultTable` (`id`) SELECT `s`.`id` FROM `tmpSourceIds` `s` LEFT OUTER JOIN `tmpClauseIds` `c` ON `s`.`id`=`c`.`id` 
				WHERE ISNULL(`c`.`id`);
					DROP TABLE `tmpSourceIds`;
				ELSE
					SELECT CONCAT("ERR: Invalid Clause Rule: ",`v_clauseRule`);
					LEAVE proc;
			END CASE;
		END IF;
	END LOOP clauseLoop;
	SET SQL_SAFE_UPDATES=0;
	IF LEFT(`p_setId`,1)='!' OR LEFT(`p_setId`,1)='?' THEN 
		-- Diagnostics
		SELECT * FROM `tmpEcl`;
		SET `p_setId`=MID(`p_setId`,2);
	END IF;
	IF LEFT(`p_setId`,1)="-" THEN
		SET `p_setId`=MID(`p_setId`,2);
		IF LENGTH(`p_setId`)>0 THEN
			DELETE FROM `config_resultsets` WHERE `setId`=`p_setId` AND `conceptId` IN (SELECT `id` FROM `ResultTable`);
		END IF;
	ELSEIF LEFT(`p_setId`,1)="+" THEN
		SET `p_setId`=MID(`p_setId`,2);
		IF LENGTH(`p_setId`)>0 THEN
			INSERT IGNORE INTO `config_resultsets` (`setId`,`conceptId`) SELECT `p_setId`,`id` FROM `ResultTable`;
		END IF;
	ELSE
		IF `p_setId`="" THEN 
			SET `p_setId`='temp';
		END IF;
		DELETE FROM `config_resultsets` WHERE `setId`=`p_setId`;
		INSERT IGNORE INTO `config_resultsets` (`setId`,`conceptId`) SELECT `p_setId`,`id` FROM `ResultTable`;
	END IF;
	SET SQL_SAFE_UPDATES=1;
	DROP TABLE IF EXISTS `tmpSourceIds`;
	DROP TABLE IF EXISTS `tmpIds`;
	DROP TABLE IF EXISTS `ResultTable`;
END;;

-- Create eclSimple() Procedure
-- This procedure only works with current snapshot
-- Next line replace by start block comment if no Transitive Closure
-- ifTC

DROP PROCEDURE IF EXISTS `eclSimple`;;
CREATE PROCEDURE eclSimple(`p_ecl` text)
BEGIN
-- SNOMED SQL QUERY FOR SIMPLE EXPRESSION CONSTRAINTS
-- Lists the id and preferred terms for all matching concepts

-- Requires a SIMPLE ECL expression constraint.
-- Call this procedure as follows:
--   CALL eclSimple("ecl_expression");
-- Examples:
--   CALL eclSimple('<404684003:363698007=<<39057004,116676008=<<415582006');
-- 	 CALL eclSimple('<404684003:363698007=<39057004,116676008=<415582006');
--   CALL eclSimple('<404684003:363698007=<<39057004');
--   CALL eclSimple('< 404684003 |clinical finding|:363698007 |finding site| = << 39057004 |pulmonary `valve|,116676008 |associated morphology| = << 415582006 |stenosis|')
 
-- Currently permits:
--    1) Just a focus concept constraint,
--    2) A focus concept constraint and one attribute value constraint
--    3) A focus concept constraint and two attribute value constraint
-- General format:
--    <<focus_id[:attr1=<<attr1_value[,attr2=<<attr2_value]]
-- In all cases
--    a) The << can be replaced by < (subtypes only) or omitted (self only)
--    b) Each identifier can be followed by pipe-delimited term which is removed before computing the matching concepts
--    c) Spaces can be included in constraints and are removed before computing the matching concepts

-- NOTE: MORE COMPLEX ECL CONSTRAINTS ARE NOT CURRENTLY SUPPORTED BY THIS DEMONSTRATOR PROCEDURE

DECLARE `v_text` text;
DECLARE `v_ecl` text;
DECLARE `v_focus_id` bigint;
DECLARE `v_focus_symbol` text;
DECLARE `v_refine1` text;
DECLARE `v_refine2` text;
DECLARE `v_ref2` text;
DECLARE `v_value1_id` bigint;
DECLARE `v_value2_id` bigint;
DECLARE `v_attr1_id` bigint;
DECLARE `v_attr2_id` bigint;
DECLARE `v_value1_symbol` text;
DECLARE `v_value2_symbol` text;
DECLARE `v_pos` int;
DECLARE `v_count` int DEFAULT 0;
DECLARE specialty CONDITION FOR SQLSTATE '45000';
DECLARE `msg` text;

SET @ver=(SELECT VERSION());
IF @ver>=8 THEN
	SET `msg`='With MySQL 8.0+. Please use the more powerful eclQuery() procedure.';
	SELECT `msg`;
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = `msg`;
END IF;

SET `v_ecl`='';

-- Copy the input parameter with a trailing pipe appended (support last iteration of pipe loop)
SET `v_text`=CONCAT(`p_ecl`,'|');

-- Loop to remove any pipe delimited terms and return a simplified constraint
pipe:WHILE `v_text` regexp '\|' DO
	SET `v_count`=`v_count`+1;
	SET `v_ecl`=CONCAT(`v_ecl`,SUBSTRING_INDEX(`v_text`,'|',1));
    SET `v_pos`=LENGTH(SUBSTRING_INDEX(`v_text`,'|',2))+2;
    IF `v_pos`<3 OR `v_pos`>LENGTH(`v_text`) THEN
        LEAVE pipe;
	ELSE
		SET `v_text`=MID(`v_text`,`v_pos`);
	END IF;
    IF `v_count`>10 THEN LEAVE pipe; END IF;
END WHILE pipe;

-- Remove all spaces in the ECL
SET `v_ecl`=REPLACE(`v_ecl`,' ','');

-- Split the focus concept constraint from any refinements
SET `v_focus_symbol`=SUBSTRING_INDEX(`v_ecl`,':',1);
IF `v_focus_symbol` != `v_ecl` THEN
	SET `v_refine1`=SUBSTRING_INDEX(`v_ecl`,':',-1);
	SET `v_refine2`=SUBSTRING_INDEX(`v_refine1`,',',-1);
ELSE
	SET `v_refine1`='';
END IF;

-- separate symbols from the focus concept id
IF LEFT(`v_focus_symbol`,2)='<<' THEN
	SET `v_focus_id`=MID(v_focus_symbol,3);
    SET `v_focus_symbol`='<<';
ELSEIF LEFT(`v_focus_symbol`,1)='<' THEN
	SET `v_focus_id`=MID(`v_focus_symbol`,2);
    SET `v_focus_symbol`='<';
ELSE
	SET `v_focus_id`=`v_focus_symbol`;
    SET `v_focus_symbol`='';
END IF;

-- check if there are 1 or two refinements
-- if there are two split them 
IF `v_refine2` != `v_refine1` THEN
	SET `v_refine1`=SUBSTRING_INDEX(`v_refine1`,',',1);
    -- Split the attribute name, symbol and value for refinement 2
    SET `v_attr2_id`=SUBSTRING_INDEX(`v_refine2`,'=',1);
    SET `v_value2_symbol`=SUBSTRING_INDEX(`v_refine2`,'=',-1);
	IF LEFT(`v_value2_symbol`,2)='<<' THEN
		SET `v_value2_id`=MID(`v_value2_symbol`,3);
		SET `v_value2_symbol`='<<';
	ELSEIF LEFT(`v_value2_symbol`,1)='<' THEN
		SET `v_value1_id`=MID(`v_value2_symbol`,2);
		SET `v_value2_symbol`='<';
	ELSE
		SET `v_value2_id`=`v_value2_symbol`;
		SET `v_value2_symbol`='';
	END IF;    
ELSE
    SET `v_refine2`='';
END IF;
-- If there is at least 1 refinement split the attribute name, symbol and value for refinement 1
IF `v_refine1` != '' THEN
    SET `v_attr1_id`=SUBSTRING_INDEX(`v_refine1`,'=',1);
    SET `v_value1_symbol`=SUBSTRING_INDEX(`v_refine1`,'=',-1);
	IF LEFT(`v_value1_symbol`,2)='<<' THEN
		SET `v_value1_id`=MID(`v_value1_symbol`,3);
		SET `v_value1_symbol`='<<';
	ELSEIF LEFT(`v_value1_symbol`,1)='<' THEN
		SET `v_value1_id`=MID(`v_value1_symbol`,2);
		SET `v_value1_symbol`='<';
	ELSE
		SET `v_value1_id`=`v_value1_symbol`;
		SET `v_value1_symbol`='';
	END IF;
END IF;

-- drop then create temporary tables for results focus and 1 or 2 refinements
DROP TABLE IF EXISTS tmp_focus;
DROP TABLE IF EXISTS tmp_ref1;
DROP TABLE IF EXISTS tmp_ref2;

-- Create temporary tables
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_focus (
  `id` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_ref1 (
  `id` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_ref2 (
  `id` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;
-- END OF PREPARATION STEPS

-- Get the results of the focus concept constraint
-- IF SUBTYPES INCLUDED ADD ALL CONCEPTS PASSING THE SUBSUMPTION TEST TO A TEMPORARY TABLE tmp_focus
IF `v_focus_symbol` = '<' OR `v_focus_symbol` = '<<' THEN
	INSERT IGNORE INTO `tmp_focus` SELECT `subtypeId` FROM `snap_transclose` as `tc` WHERE `tc`.`supertypeId` = `v_focus_id`;
END IF;

-- IF SELF INCLUDED ADD FOCUS CONCEPT TO TEMPORARY TABLE tmp_focus
IF `v_focus_symbol` = '' OR `v_focus_symbol` = '<<' THEN
	INSERT IGNORE INTO `tmp_focus` VALUES (`v_focus_id`);
END IF;


-- Get the results of the first refinement constraint
-- ADD ALL CONCEPTS PASSING THE FIRST ATTRIBUTE VALUE TEST TO TEMPORARY TABLE tmp_ref1
IF `v_refine1` != '' THEN
	IF `v_value1_symbol` = '<' OR `v_value1_symbol` = '<<' THEN
		INSERT IGNORE INTO `tmp_ref1` SELECT DISTINCT `sourceId` FROM `snap_relationship` as `r` WHERE `r`.`active` = 1 AND `r`.`typeId` = `v_attr1_id` 
		AND `r`.`destinationId` IN (SELECT `tc`.`subTypeId` FROM `snap_transclose` as `tc`
		WHERE `tc`.`supertypeId` = `v_value1_id` );
	END IF;
    IF `v_value1_symbol` = '' OR `v_value1_symbol` = '<<' THEN
		INSERT IGNORE INTO `tmp_ref1` SELECT DISTINCT `sourceId` FROM `snap_relationship` as `r` WHERE `r`.`active` = 1 AND `r`.`typeId` = `v_attr1_id` 
		AND `r`.`destinationId` = `v_value1_id`;
    END IF;
END IF;

-- Get the results of the second refinement constraint
-- ADD ALL CONCEPTS PASSING THE SECOND ATTRIBUTE VALUE TEST TO TEMPORARY TABLE tmp_ref2
IF `v_refine2` != '' THEN
	IF `v_value2_symbol` = '<' OR `v_value2_symbol` = '<<' THEN
		INSERT IGNORE INTO `tmp_ref2` SELECT DISTINCT `sourceId` FROM `snap_relationship` as `r` WHERE `r`.`active` = 1 AND `r`.`typeId` = `v_attr2_id` 
		AND `r`.`destinationId` IN (SELECT `tc`.`subTypeId` FROM `snap_transclose` as `tc`
		WHERE `tc`.`supertypeId` = `v_value2_id` );
	END IF;
    IF `v_value2_symbol` = '' OR `v_value2_symbol` = '<<' THEN
		INSERT IGNORE INTO `tmp_ref2` SELECT DISTINCT `sourceId` FROM `snap_relationship` as `r` WHERE `r`.`active` = 1 AND `r`.`typeId` = `v_attr2_id` 
		AND `r`.`destinationId` = `v_value2_id`;
    END IF;
END IF;

-- LIST ALL THE CONCEPT THAT ARE IN ALL THREE TEMPORARY TABLES

IF `v_refine1` = '' THEN
-- If no refinements this is simply the concepts in tmp_focus
	SELECT `pt`.`conceptId`,`pt`.`term`
	FROM `tmp_focus`, `snap_pref` as `pt`
		WHERE  `pt`.`conceptId` = `tmp_focus`.`id` 
		ORDER BY `pt`.`term`;

ELSEIF `v_refine2` = '' THEN
-- If there is only one refinement constraint only list concepts found BOTH in tmp_focus AND in tmp_ref1
	SELECT `pt`.`conceptId`,`pt`.`term`
	FROM `tmp_focus`, `snap_pref` as `pt`
		WHERE  `pt`.`conceptId` = `tmp_focus`.`id` 
		AND `tmp_focus`.`id` IN (SELECT `id` FROM `tmp_ref1`)
		ORDER BY `pt`.`term`;

ELSE
-- If there are two refinement constraints only list concepts found in ALL three table tmp_focus AND tmp_ref1 AND tmp_ref2
	SELECT `pt`.`conceptId`,`pt`.`term` `prefTerm`
	FROM `tmp_focus`, `snap_pref` as `pt`
		WHERE  `pt`.`conceptId` = `tmp_focus`.`id` 
		AND `pt`.`conceptId` IN (SELECT `id` FROM `tmp_ref1`)
		AND `pt`.`conceptId` IN (SELECT `id` FROM `tmp_ref2`)
		ORDER BY `pt`.`term`;

END IF;

-- Remove the temporary tables
DROP TABLE IF EXISTS `tmp_focus`;
DROP TABLE IF EXISTS `tmp_ref1`;
DROP TABLE IF EXISTS `tmp_ref2`;

END;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `snap_SearchPlus`;
DELIMITER ;;
CREATE PROCEDURE `snap_SearchPlus`(`p_search` text,`p_filter` text)
BEGIN
-- 
-- snap_SearchPlus(p_search,p_filter)
--   p_search: string for fulltext search 
--    (if it includes + or - the uses boolean mode otherwise natural language mode).
--   p_filter: string for either
--          Regular expression filtering (Starting '!' negates the search) or
--          Subsumption filtering if starts with '<' followed by id or a shortcut term.
--          See config_shortcuts table (created and populated in this part of the script)
-- Specify using one of the following options:
-- FULL TEXT SEARCH
-- p_search (with empty p_filter string)
-- Examples:
--     CALL snap_SearchPlus('fundus stomach', '');
--     CALL snap_SearchPlus('+fundus +stomach','');
--     CALL snap_SearchPlus('+lung +disease -chronic','');
-- REGULAR EXPRESSION SEARCH
-- p_filter (with empty p_filter string)
-- Examples: (These queries can be very slow)
--     CALL snap_SearchPlus('', '^[Ff]undus.*ch');
--     CALL snap_SearchPlus('', '.+fundus.+');
-- FULLTEXT SEARCH FILTERED BY REGULAR EXPRESSION
-- p_search and p_filter string. 
--   Examples:
--     CALL snap_SearchPlus('+fundus', 'ch');
--     CALL snap_SearchPlus('stomach','!(eye|oculi|uter)');
--     CALL snap_SearchPlus('+lung +disease +chronic','oe?dema');
--     CALL snap_SearchPlus('appendix','<proc');
--     CALL snap_SearchPlus('hemoglobin','<lab');
--     CALL snap_SearchPlus('infection','<19829001');
-- SORT ORDER:
--    Natural language mode sorted by fulltext relevance.
--    Other modes sorted by shortest term
--
-- OPTION to use short cuts in subsumption tests

IF LEFT(`p_filter`,1)='<' AND 'snap'!='snap' THEN
	SELECT 0,'Subtype tests are only supported for current snapshot view.';
ELSE

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' THEN
			SELECT `id`,`term` FROM `snap_rel_child_pref` `p` WHERE `p`.`conceptId`=SUBSTRING_INDEX(`p_filter`,'<',-1) ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE `term` regexp `p_filter` ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF `p_filter`='' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='<' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='!' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) LIMIT 200;
		END IF;
    ELSE
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` regexp `p_filter` ORDER BY length(`term`)  LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` regexp `p_filter`  LIMIT 200;
		END IF;
	END IF;
END IF;
END;;
DELIMITER ;
DROP PROCEDURE IF EXISTS `snap1_SearchPlus`;
DELIMITER ;;
CREATE PROCEDURE `snap1_SearchPlus`(`p_search` text,`p_filter` text)
BEGIN
-- 
-- snap_SearchPlus(p_search,p_filter)
--   p_search: string for fulltext search 
--    (if it includes + or - the uses boolean mode otherwise natural language mode).
--   p_filter: string for either
--          Regular expression filtering (Starting '!' negates the search) or
--          Subsumption filtering if starts with '<' followed by id or a shortcut term.
--          See config_shortcuts table (created and populated in this part of the script)
-- Specify using one of the following options:
-- FULL TEXT SEARCH
-- p_search (with empty p_filter string)
-- Examples:
--     CALL snap_SearchPlus('fundus stomach', '');
--     CALL snap_SearchPlus('+fundus +stomach','');
--     CALL snap_SearchPlus('+lung +disease -chronic','');
-- REGULAR EXPRESSION SEARCH
-- p_filter (with empty p_filter string)
-- Examples: (These queries can be very slow)
--     CALL snap_SearchPlus('', '^[Ff]undus.*ch');
--     CALL snap_SearchPlus('', '.+fundus.+');
-- FULLTEXT SEARCH FILTERED BY REGULAR EXPRESSION
-- p_search and p_filter string. 
--   Examples:
--     CALL snap_SearchPlus('+fundus', 'ch');
--     CALL snap_SearchPlus('stomach','!(eye|oculi|uter)');
--     CALL snap_SearchPlus('+lung +disease +chronic','oe?dema');
--     CALL snap_SearchPlus('appendix','<proc');
--     CALL snap_SearchPlus('hemoglobin','<lab');
--     CALL snap_SearchPlus('infection','<19829001');
-- SORT ORDER:
--    Natural language mode sorted by fulltext relevance.
--    Other modes sorted by shortest term
--
-- OPTION to use short cuts in subsumption tests

IF LEFT(`p_filter`,1)='<' AND 'snap1'!='snap' THEN
	SELECT 0,'Subtype tests are only supported for current snapshot view.';
ELSE

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' THEN
			SELECT `id`,`term` FROM `snap_rel_child_pref` `p` WHERE `p`.`conceptId`=SUBSTRING_INDEX(`p_filter`,'<',-1) ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE `term` regexp `p_filter` ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF `p_filter`='' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='<' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='!' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) LIMIT 200;
		END IF;
    ELSE
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` regexp `p_filter` ORDER BY length(`term`)  LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` regexp `p_filter`  LIMIT 200;
		END IF;
	END IF;
END IF;
END;;
DELIMITER ;
DROP PROCEDURE IF EXISTS `snap2_SearchPlus`;
DELIMITER ;;
CREATE PROCEDURE `snap2_SearchPlus`(`p_search` text,`p_filter` text)
BEGIN
-- 
-- snap_SearchPlus(p_search,p_filter)
--   p_search: string for fulltext search 
--    (if it includes + or - the uses boolean mode otherwise natural language mode).
--   p_filter: string for either
--          Regular expression filtering (Starting '!' negates the search) or
--          Subsumption filtering if starts with '<' followed by id or a shortcut term.
--          See config_shortcuts table (created and populated in this part of the script)
-- Specify using one of the following options:
-- FULL TEXT SEARCH
-- p_search (with empty p_filter string)
-- Examples:
--     CALL snap_SearchPlus('fundus stomach', '');
--     CALL snap_SearchPlus('+fundus +stomach','');
--     CALL snap_SearchPlus('+lung +disease -chronic','');
-- REGULAR EXPRESSION SEARCH
-- p_filter (with empty p_filter string)
-- Examples: (These queries can be very slow)
--     CALL snap_SearchPlus('', '^[Ff]undus.*ch');
--     CALL snap_SearchPlus('', '.+fundus.+');
-- FULLTEXT SEARCH FILTERED BY REGULAR EXPRESSION
-- p_search and p_filter string. 
--   Examples:
--     CALL snap_SearchPlus('+fundus', 'ch');
--     CALL snap_SearchPlus('stomach','!(eye|oculi|uter)');
--     CALL snap_SearchPlus('+lung +disease +chronic','oe?dema');
--     CALL snap_SearchPlus('appendix','<proc');
--     CALL snap_SearchPlus('hemoglobin','<lab');
--     CALL snap_SearchPlus('infection','<19829001');
-- SORT ORDER:
--    Natural language mode sorted by fulltext relevance.
--    Other modes sorted by shortest term
--
-- OPTION to use short cuts in subsumption tests

IF LEFT(`p_filter`,1)='<' AND 'snap2'!='snap' THEN
	SELECT 0,'Subtype tests are only supported for current snapshot view.';
ELSE

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' THEN
			SELECT `id`,`term` FROM `snap_rel_child_pref` `p` WHERE `p`.`conceptId`=SUBSTRING_INDEX(`p_filter`,'<',-1) ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE `term` regexp `p_filter` ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF `p_filter`='' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='<' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='!' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) LIMIT 200;
		END IF;
    ELSE
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` regexp `p_filter` ORDER BY length(`term`)  LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` regexp `p_filter`  LIMIT 200;
		END IF;
	END IF;
END IF;
END;;
DELIMITER ;
DROP PROCEDURE IF EXISTS `snap_termsInLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap_termsInLanguages`(`p_conceptIds` text,`p_langCodes` text)
proc:BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms for
-- Concepts in a comma separated list of ids
-- In languages or dialects in a comma separated list of language codes.
-- Only works for languages/dialects in the release files.
-- So with International Release can be tested with calls like the following.
--   CALL snap_termsInLanguages('80146002,49438003','en-GB,en-US');
-- However, if other language description files and language refsets are imported those can also be included.
--
-- SAVE CURRENT LANGUAGE SETTING - so it can be restored later.
DECLARE `v_conceptId` text;
DECLARE `v_langCode` text;
DECLARE `v_defaultLanguage` text;
DECLARE `v_cptcount` INT DEFAULT 1;
DECLARE `v_langcount` INT DEFAULT 1;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=0);

-- CREATE TEMPORARY TABLE - for terms from the two languages
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` bigint,`type_and_lang` text,`term` text);

SET `p_conceptIds`=CONCAT(`p_conceptIds`,',');
SET `p_langCodes`=CONCAT(`p_langCodes`,',');

-- LOOP FOR CONCEPTS
    SET `v_cptcount`=1;
conceptIds:LOOP
    SET `v_conceptId`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_conceptIds`,',',`v_cptcount`),',',-1);
    IF `v_conceptId` not regexp '[1-9][0-9]{5,17}' THEN
        LEAVE conceptIds;
    END IF;
    SET `v_cptcount`=`v_cptcount`+1;

    -- LOOP FOR LANGUAGES
    SET `v_langcount`=1;
    langCodes:LOOP
        SET `v_langCode`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_langCodes`,',',`v_langcount`),',',-1);
        IF `v_langCode` not regexp '^[a-z]{2}' THEN
            LEAVE langCodes;
        END IF;
        SET `v_langcount`=`v_langcount`+1;

        CALL setLanguage(0,`v_langCode`);
        INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
        SELECT `conceptid`,CONCAT('FSN',' ',`v_langCode`) `type and lang`,`term` FROM `snap_fsn` 
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Preferred',' ', `v_langCode`) `type and lang`,`term` FROM `snap_pref`
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Synonyms',' ',`v_langCode`) `type and lang`,`term` FROM `snap_syn` 
            WHERE `conceptId`=`v_conceptId`;
    END LOOP;
END LOOP;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(0,`v_defaultLanguage`);
END;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `snap1_termsInLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap1_termsInLanguages`(`p_conceptIds` text,`p_langCodes` text)
proc:BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms for
-- Concepts in a comma separated list of ids
-- In languages or dialects in a comma separated list of language codes.
-- Only works for languages/dialects in the release files.
-- So with International Release can be tested with calls like the following.
--   CALL snap_termsInLanguages('80146002,49438003','en-GB,en-US');
-- However, if other language description files and language refsets are imported those can also be included.
--
-- SAVE CURRENT LANGUAGE SETTING - so it can be restored later.
DECLARE `v_conceptId` text;
DECLARE `v_langCode` text;
DECLARE `v_defaultLanguage` text;
DECLARE `v_cptcount` INT DEFAULT 1;
DECLARE `v_langcount` INT DEFAULT 1;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=1);

-- CREATE TEMPORARY TABLE - for terms from the two languages
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` bigint,`type_and_lang` text,`term` text);

SET `p_conceptIds`=CONCAT(`p_conceptIds`,',');
SET `p_langCodes`=CONCAT(`p_langCodes`,',');

-- LOOP FOR CONCEPTS
    SET `v_cptcount`=1;
conceptIds:LOOP
    SET `v_conceptId`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_conceptIds`,',',`v_cptcount`),',',-1);
    IF `v_conceptId` not regexp '[1-9][0-9]{5,17}' THEN
        LEAVE conceptIds;
    END IF;
    SET `v_cptcount`=`v_cptcount`+1;

    -- LOOP FOR LANGUAGES
    SET `v_langcount`=1;
    langCodes:LOOP
        SET `v_langCode`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_langCodes`,',',`v_langcount`),',',-1);
        IF `v_langCode` not regexp '^[a-z]{2}' THEN
            LEAVE langCodes;
        END IF;
        SET `v_langcount`=`v_langcount`+1;

        CALL setLanguage(1,`v_langCode`);
        INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
        SELECT `conceptid`,CONCAT('FSN',' ',`v_langCode`) `type and lang`,`term` FROM `snap_fsn` 
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Preferred',' ', `v_langCode`) `type and lang`,`term` FROM `snap_pref`
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Synonyms',' ',`v_langCode`) `type and lang`,`term` FROM `snap_syn` 
            WHERE `conceptId`=`v_conceptId`;
    END LOOP;
END LOOP;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(1,`v_defaultLanguage`);
END;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `snap2_termsInLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap2_termsInLanguages`(`p_conceptIds` text,`p_langCodes` text)
proc:BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms for
-- Concepts in a comma separated list of ids
-- In languages or dialects in a comma separated list of language codes.
-- Only works for languages/dialects in the release files.
-- So with International Release can be tested with calls like the following.
--   CALL snap_termsInLanguages('80146002,49438003','en-GB,en-US');
-- However, if other language description files and language refsets are imported those can also be included.
--
-- SAVE CURRENT LANGUAGE SETTING - so it can be restored later.
DECLARE `v_conceptId` text;
DECLARE `v_langCode` text;
DECLARE `v_defaultLanguage` text;
DECLARE `v_cptcount` INT DEFAULT 1;
DECLARE `v_langcount` INT DEFAULT 1;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=2);

-- CREATE TEMPORARY TABLE - for terms from the two languages
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` bigint,`type_and_lang` text,`term` text);

SET `p_conceptIds`=CONCAT(`p_conceptIds`,',');
SET `p_langCodes`=CONCAT(`p_langCodes`,',');

-- LOOP FOR CONCEPTS
    SET `v_cptcount`=1;
conceptIds:LOOP
    SET `v_conceptId`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_conceptIds`,',',`v_cptcount`),',',-1);
    IF `v_conceptId` not regexp '[1-9][0-9]{5,17}' THEN
        LEAVE conceptIds;
    END IF;
    SET `v_cptcount`=`v_cptcount`+1;

    -- LOOP FOR LANGUAGES
    SET `v_langcount`=1;
    langCodes:LOOP
        SET `v_langCode`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_langCodes`,',',`v_langcount`),',',-1);
        IF `v_langCode` not regexp '^[a-z]{2}' THEN
            LEAVE langCodes;
        END IF;
        SET `v_langcount`=`v_langcount`+1;

        CALL setLanguage(2,`v_langCode`);
        INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
        SELECT `conceptid`,CONCAT('FSN',' ',`v_langCode`) `type and lang`,`term` FROM `snap_fsn` 
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Preferred',' ', `v_langCode`) `type and lang`,`term` FROM `snap_pref`
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Synonyms',' ',`v_langCode`) `type and lang`,`term` FROM `snap_syn` 
            WHERE `conceptId`=`v_conceptId`;
    END LOOP;
END LOOP;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(2,`v_defaultLanguage`);
END;;

DELIMITER ;
DELIMITER ;;
DROP FUNCTION IF EXISTS `snap_RefsetNames`;;
CREATE FUNCTION `snap_RefsetNames`() RETURNS text
BEGIN
--
-- Return a JSON representation of the refset names (as preferred terms);
-- Refset name concepts are by definition concepts that are subtype descendants of concept 900000000000455006
-- that do NOT have any subtype children (those with subtype children represent either refset type or groups of
-- refsets linked in some way.)
--
DECLARE done INT DEFAULT FALSE;

DECLARE namedata TEXT;
DECLARE sep VARCHAR(1) DEFAULT '';
DECLARE alldata TEXT DEFAULT '{';
DECLARE rsname CURSOR FOR SELECT CONCAT('"',`conceptId`,'":{"term":"',`term`,'","rows":0,"table":"-","files":{}}') FROM `snap_pref` WHERE `conceptId` IN (SELECT 
			`tc1`.`subtypeId` FROM (`snap_transclose` `tc1` LEFT JOIN `snap_transclose` `tc2` ON ((`tc1`.`subtypeId` = `tc2`.`supertypeId`))) WHERE ((`tc1`.`supertypeId` = 900000000000455006)
                    AND ISNULL(`tc2`.`subtypeId`)));
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN rsname;
GETRSNAMES: LOOP
	FETCH rsname INTO namedata;
	IF done THEN
		LEAVE GETRSNAMES;
	END IF;
	SET alldata=CONCAT(alldata,sep,namedata);
	SET sep=',';
END LOOP;
close rsname;
RETURN CONCAT(alldata,'}');

END;;

DELIMITER ;;
DROP FUNCTION IF EXISTS `getMrcmRefsetId`;;
CREATE FUNCTION `getMrcmRefsetId`(`p_moduleId` BIGINT,`p_refsetType` TEXT) RETURNS BIGINT
BEGIN

-- Return refsetId of a specified type MRCM refset for a specified module
-- First parameter is a module Id 
-- Second parameter is string representing the MRCM set type:
-- Either "d" or "mrcmdomain" returns the id of the MRCM Domain Refset
-- Either "a" or "mrcmattributedomain" returns the id of the MRCM Attribute Domain Refset
-- Either "r" or "mrcmattributerange" returns the id of the MRCM Attribute Range Refset

	DECLARE `v_refsetType` TEXT;
	CASE LOWER(LEFT(`p_refsetType`,1))
		WHEN 'd' THEN
			SET `v_refsetType`='mrcmdomain';
			WHEN 'a' THEN
			SET `v_refsetType`='mrcmattributedomain';
			WHEN 'r' THEN
			SET `v_refsetType`='mrcmattributerange';
		ELSE
			SET `v_refsetType`=LOWER(`p_refsetType`);
	END CASE;
	RETURN (SELECT `mrcmRuleRefsetId` 
		FROM `snap_refset_mrcmmodulescope` `m`
			JOIN `config_refsets` `r` ON `r`.`refsetId`=`m`.`mrcmRuleRefsetId`
			WHERE `active`=1 AND `m`.`refsetId`=723563008
			AND `r`.`refsetType`=`v_refsetType`
			AND referencedComponentId=`p_moduleId`);
END;;
DELIMITER ;


-- ===========================================
-- START INDEX
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"START INDEX";


-- Add Additional Indexes --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Add Additional Indexes";


-- Create Indexes for Prefix: full --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Indexes for Prefix: full";


-- Index full_refset_simple --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_simple";

CALL CreateIndexIfNotExists('full_refset_simple','sct_refset_simple_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_simple','sct_refset_simple_rc','refsetId,referencedComponentId');

-- Index full_refset_association --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_association";

CALL CreateIndexIfNotExists('full_refset_association','sct_refset_association_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_association','sct_refset_association_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_association','sct_refset_association_tgt','refsetId,targetComponentId');

-- Index full_refset_attributevalue --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_attributevalue";

CALL CreateIndexIfNotExists('full_refset_attributevalue','sct_refset_attributevalue_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_attributevalue','sct_refset_attributevalue_rc','refsetId,referencedComponentId');

-- Index full_refset_QuerySpecificationReferenceSet --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_QuerySpecificationReferenceSet";


-- Index full_refset_language --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_language";

CALL CreateIndexIfNotExists('full_refset_language','sct_refset_language_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_language','sct_refset_language_rc','refsetId,referencedComponentId');

-- Index full_refset_extendedmap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_extendedmap";

CALL CreateIndexIfNotExists('full_refset_extendedmap','sct_refset_extendedmap_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_extendedmap','sct_refset_extendedmap_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_extendedmap','sct_refset_extendedmap_map','mapTarget');

-- Index full_refset_simplemap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_simplemap";

CALL CreateIndexIfNotExists('full_refset_simplemap','sct_refset_simplemap_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_simplemap','sct_refset_simplemap_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_simplemap','sct_refset_simplemap_map','mapTarget');

-- Index full_refset_mrcmmodulescope --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_mrcmmodulescope";

CALL CreateIndexIfNotExists('full_refset_mrcmmodulescope','sct_refset_mrcmmodulescope_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_mrcmmodulescope','sct_refset_mrcmmodulescope_rc','refsetId,referencedComponentId');

-- Index full_refset_refsetdescriptor --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_refsetdescriptor";

CALL CreateIndexIfNotExists('full_refset_refsetdescriptor','sct_refset_refsetdescriptor_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_refsetdescriptor','sct_refset_refsetdescriptor_rc','refsetId,referencedComponentId');

-- Index full_refset_descriptiontype --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_descriptiontype";


-- Index full_refset_mrcmattributedomain --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_mrcmattributedomain";

CALL CreateIndexIfNotExists('full_refset_mrcmattributedomain','sct_refset_mrcmattributedomain_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_mrcmattributedomain','sct_refset_mrcmattributedomain_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_mrcmattributedomain','sct_refset_mrcmattributedomain_dom','domainId');

-- Index full_refset_moduledependency --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_moduledependency";

CALL CreateIndexIfNotExists('full_refset_moduledependency','sct_refset_moduledependency_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_moduledependency','sct_refset_moduledependency_rc','refsetId,referencedComponentId');

-- Index full_refset_mrcmattributerange --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_mrcmattributerange";

CALL CreateIndexIfNotExists('full_refset_mrcmattributerange','sct_refset_mrcmattributerange_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_mrcmattributerange','sct_refset_mrcmattributerange_rc','refsetId,referencedComponentId');

-- Index full_refset_mrcmdomain --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_mrcmdomain";

CALL CreateIndexIfNotExists('full_refset_mrcmdomain','sct_refset_mrcmdomain_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_mrcmdomain','sct_refset_mrcmdomain_rc','refsetId,referencedComponentId');

-- Index full_concept --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_concept";


-- Index full_description --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_description";

CALL CreateIndexIfNotExists('full_description','sct_description_concept','conceptId');
CALL CreateIndexIfNotExists('full_description','sct_description_lang','conceptId,languageCode');
CALL CreateIndexIfNotExists('full_description','sct_description_term_ft','term');

-- Index full_relationshipconcretevalues --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_relationshipconcretevalues";

CALL CreateIndexIfNotExists('full_relationshipconcretevalues','sct_relationshipconcretevalues_source','sourceId,typeId,characteristicTypeId');

-- Index full_relationship --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_relationship";

CALL CreateIndexIfNotExists('full_relationship','sct_relationship_source','sourceId,typeId,destinationId');
CALL CreateIndexIfNotExists('full_relationship','sct_relationship_dest','destinationId,typeId,sourceId');

-- Index full_description --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_description";

CALL CreateIndexIfNotExists('full_description','sct_description_concept','conceptId');
CALL CreateIndexIfNotExists('full_description','sct_description_lang','conceptId,languageCode');
CALL CreateIndexIfNotExists('full_description','sct_description_term_ft','term');

-- Index full_refset_owlexpression --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_owlexpression";

CALL CreateIndexIfNotExists('full_refset_owlexpression','sct_refset_owlexpression_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_owlexpression','sct_refset_owlexpression_rc','refsetId,referencedComponentId');
;


-- Create Indexes for Prefix: snap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Indexes for Prefix: snap";


-- Index snap_refset_simple --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_simple";

CALL CreateIndexIfNotExists('snap_refset_simple','sct_refset_simple_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_simple','sct_refset_simple_rc','refsetId,referencedComponentId');

-- Index snap_refset_association --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_association";

CALL CreateIndexIfNotExists('snap_refset_association','sct_refset_association_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_association','sct_refset_association_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_association','sct_refset_association_tgt','refsetId,targetComponentId');

-- Index snap_refset_attributevalue --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_attributevalue";

CALL CreateIndexIfNotExists('snap_refset_attributevalue','sct_refset_attributevalue_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_attributevalue','sct_refset_attributevalue_rc','refsetId,referencedComponentId');

-- Index snap_refset_QuerySpecificationReferenceSet --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_QuerySpecificationReferenceSet";


-- Index snap_refset_language --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_language";

CALL CreateIndexIfNotExists('snap_refset_language','sct_refset_language_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_language','sct_refset_language_rc','refsetId,referencedComponentId');

-- Index snap_refset_extendedmap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_extendedmap";

CALL CreateIndexIfNotExists('snap_refset_extendedmap','sct_refset_extendedmap_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_extendedmap','sct_refset_extendedmap_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_extendedmap','sct_refset_extendedmap_map','mapTarget');

-- Index snap_refset_simplemap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_simplemap";

CALL CreateIndexIfNotExists('snap_refset_simplemap','sct_refset_simplemap_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_simplemap','sct_refset_simplemap_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_simplemap','sct_refset_simplemap_map','mapTarget');

-- Index snap_refset_mrcmmodulescope --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_mrcmmodulescope";

CALL CreateIndexIfNotExists('snap_refset_mrcmmodulescope','sct_refset_mrcmmodulescope_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_mrcmmodulescope','sct_refset_mrcmmodulescope_rc','refsetId,referencedComponentId');

-- Index snap_refset_refsetdescriptor --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_refsetdescriptor";

CALL CreateIndexIfNotExists('snap_refset_refsetdescriptor','sct_refset_refsetdescriptor_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_refsetdescriptor','sct_refset_refsetdescriptor_rc','refsetId,referencedComponentId');

-- Index snap_refset_descriptiontype --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_descriptiontype";


-- Index snap_refset_mrcmattributedomain --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_mrcmattributedomain";

CALL CreateIndexIfNotExists('snap_refset_mrcmattributedomain','sct_refset_mrcmattributedomain_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_mrcmattributedomain','sct_refset_mrcmattributedomain_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_mrcmattributedomain','sct_refset_mrcmattributedomain_dom','domainId');

-- Index snap_refset_moduledependency --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_moduledependency";

CALL CreateIndexIfNotExists('snap_refset_moduledependency','sct_refset_moduledependency_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_moduledependency','sct_refset_moduledependency_rc','refsetId,referencedComponentId');

-- Index snap_refset_mrcmattributerange --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_mrcmattributerange";

CALL CreateIndexIfNotExists('snap_refset_mrcmattributerange','sct_refset_mrcmattributerange_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_mrcmattributerange','sct_refset_mrcmattributerange_rc','refsetId,referencedComponentId');

-- Index snap_refset_mrcmdomain --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_mrcmdomain";

CALL CreateIndexIfNotExists('snap_refset_mrcmdomain','sct_refset_mrcmdomain_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_mrcmdomain','sct_refset_mrcmdomain_rc','refsetId,referencedComponentId');

-- Index snap_concept --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_concept";


-- Index snap_description --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_description";

CALL CreateIndexIfNotExists('snap_description','sct_description_concept','conceptId');
CALL CreateIndexIfNotExists('snap_description','sct_description_lang','conceptId,languageCode');
CALL CreateIndexIfNotExists('snap_description','sct_description_term_ft','term');

-- Index snap_relationshipconcretevalues --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_relationshipconcretevalues";

CALL CreateIndexIfNotExists('snap_relationshipconcretevalues','sct_relationshipconcretevalues_source','sourceId,typeId,characteristicTypeId');

-- Index snap_relationship --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_relationship";

CALL CreateIndexIfNotExists('snap_relationship','sct_relationship_source','sourceId,typeId,destinationId');
CALL CreateIndexIfNotExists('snap_relationship','sct_relationship_dest','destinationId,typeId,sourceId');

-- Index snap_description --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_description";

CALL CreateIndexIfNotExists('snap_description','sct_description_concept','conceptId');
CALL CreateIndexIfNotExists('snap_description','sct_description_lang','conceptId,languageCode');
CALL CreateIndexIfNotExists('snap_description','sct_description_term_ft','term');

-- Index snap_refset_owlexpression --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_owlexpression";

CALL CreateIndexIfNotExists('snap_refset_owlexpression','sct_refset_owlexpression_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_owlexpression','sct_refset_owlexpression_rc','refsetId,referencedComponentId');
;


-- END INDEX --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END INDEX";

