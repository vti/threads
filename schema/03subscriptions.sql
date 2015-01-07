ALTER TABLE `users` ADD COLUMN email_notifications INT NOT NULL DEFAULT 1;
ALTER TABLE `users` ADD COLUMN notify_when_replied INT NOT NULL DEFAULT 1;
ALTER TABLE `users` ADD COLUMN auto_subscribe INT NOT NULL DEFAULT 1;

DROP TABLE IF EXISTS `subscriptions`;
CREATE TABLE `subscriptions` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` INT NOT NULL,
  `thread_id` INT NOT NULL,
  `created` integer(4) not null default (strftime('%s','now'))
);
