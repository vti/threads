ALTER TABLE `threads` ADD COLUMN `views_count` INT NOT NULL DEFAULT 0;

DROP TABLE IF EXISTS `views`;
CREATE TABLE `views` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` INT NOT NULL DEFAULT 0,
  `thread_id` INT NOT NULL,
  `created` integer(4) not null default (strftime('%s','now')),
  `hash` varchar(32) NOT NULL DEFAULT ''
);
