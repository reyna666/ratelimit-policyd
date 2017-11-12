-- User: policyd@localhost
-- GRANT USAGE ON *.* TO policyd@'localhost' IDENTIFIED BY '********';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON policyd.* TO policyd@'localhost';

-- -----------------------------------------------------
-- Schema policyd
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `policyd` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

USE `policyd`;

-- -----------------------------------------------------
-- Table `policyd`.`ratelimit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ratelimit` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`sender` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NOT NULL COMMENT 'sender address (SASL username)',
	`persist` TINYINT(1) NOT NULL DEFAULT '0' COMMENT 'Do not reset the given quota to the default value after expiry reached.',
	`quota` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'hourly|daily|weekly|monthly recipient quota limit',
	`used` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'current recipient counter',
	`updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'when used counter was last updated',
	`expiry` INT(10) UNSIGNED DEFAULT '0' COMMENT 'expiry (Unix-timestamp) after which the counter gets reset',
	PRIMARY KEY (`id`),
	UNIQUE INDEX `idx_sender` (`sender` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;

-- -----------------------------------------------------
-- Table `policyd`.`view_ratelimit`
-- -----------------------------------------------------
CREATE OR REPLACE VIEW `view_ratelimit` AS SELECT *, FROM_UNIXTIME(`expiry`) AS `expirytime` FROM `ratelimit`;


-- -----------------------------------------------------
-- PATCHES
-- -----------------------------------------------------

-- patch 001 (2015-01-10)
/*
ALTER TABLE `ratelimit` ADD `updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `used`;
UPDATE `ratelimit` SET `updated` = NOW();
*/

-- patch 002 (2015-01-10)
/*
ALTER TABLE `ratelimit` MODIFY `sender` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NOT NULL COMMENT 'sender address (SASL username)';
ALTER TABLE `ratelimit` MODIFY `quota` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'hourly|daily|weekly|monthly recipient quota limit';
ALTER TABLE `ratelimit` MODIFY `used` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'current recipient counter';
ALTER TABLE `ratelimit` MODIFY `updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'when used counter was last updated';
ALTER TABLE `ratelimit` MODIFY `expiry` INT(10) UNSIGNED DEFAULT '0' COMMENT 'expiry (Unix-timestamp) after which the counter gets reset';
ALTER TABLE `ratelimit` ADD `persist` TINYINT(1) NOT NULL DEFAULT '0' COMMENT 'Do not reset the given quota to the default value after expiry reached.' AFTER `sender`;
*/

CREATE TABLE `user_quota` (
  `email` varchar(200) NOT NULL DEFAULT '',
  `quota` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;