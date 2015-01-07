DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(32) NOT NULL DEFAULT '',
  `name` VARCHAR(32) NOT NULL DEFAULT '',
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

DROP TABLE IF EXISTS `threads`;
CREATE TABLE `threads` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` INT NOT NULL,
  `created` integer(4) not null default (strftime('%s','now')),
  `title` VARCHAR(32) NOT NULL DEFAULT '',
  `replies_count` INT NOT NULL DEFAULT 0,
  `content` TEXT NOT NULL DEFAULT ''
);

DROP TABLE IF EXISTS `replies`;
CREATE TABLE `replies` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` INT NOT NULL,
  `thread_id` INT NOT NULL,
  `parent_id` INT NOT NULL DEFAULT 0,
  `level` integer not null,
  `lft` integer not null,
  `rgt` integer not null,
  `created` integer(4) not null default (strftime('%s','now')),
  `content` TEXT NOT NULL DEFAULT ''
);
