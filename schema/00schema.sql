DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(32) NOT NULL DEFAULT '',
  `status` VARCHAR(255) NOT NULL DEFAULT 'new',
  `created` integer(4) not null default (strftime('%s','now')),
  UNIQUE (`email`)
);

DROP TABLE IF EXISTS `confirmations`;
CREATE TABLE `confirmations` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` INT NOT NULL,
  `token` VARCHAR(32) NOT NULL DEFAULT '',
  `created` integer(4) not null default (strftime('%s','now')),
  UNIQUE (`token`)
);
