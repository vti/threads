DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` INT NOT NULL,
  `reply_id` INT NOT NULL,
  `created` integer(4) not null default (strftime('%s','now')),
  UNIQUE(`user_id`,`reply_id`)
);
