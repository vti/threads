ALTER TABLE `replies` ADD COLUMN `reports_count` NOT NULL DEFAULT 0;

DROP TABLE IF EXISTS `reports`;
CREATE TABLE `reports` (
  `id` INTEGER NOT NULL PRIMARY KEY,
  `user_id` INTEGER NOT NULL,
  `reply_id` INTEGER NOT NULL,
  `created` integer(4) not null default (strftime('%s','now'))
);
