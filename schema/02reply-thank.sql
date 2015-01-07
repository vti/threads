ALTER TABLE `replies` ADD COLUMN `thanks_count` INT NOT NULL DEFAULT 0;

DROP TABLE IF EXISTS `thanks`;
CREATE TABLE `thanks` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` INT NOT NULL,
  `reply_id` INT NOT NULL,
  `created` integer(4) not null default (strftime('%s','now'))
);
