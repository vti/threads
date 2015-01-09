DROP TABLE IF EXISTS `disposable_email_blacklist`;
CREATE TABLE `disposable_email_blacklist` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `domain` VARCHAR(64) NOT NULL,
  UNIQUE (`domain`)
);
