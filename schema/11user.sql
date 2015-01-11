BEGIN TRANSACTION;

ALTER TABLE `users` RENAME to `users_old`;

CREATE TABLE `users` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `password` BLOB NOT NULL DEFAULT '',
  `salt` BLOB NOT NULL DEFAULT '',
  `name` VARCHAR(32) NOT NULL DEFAULT '',
  `status` VARCHAR(32) NOT NULL DEFAULT 'new',
  `email_notifications` INT NOT NULL DEFAULT 1,
  `created` integer(4) not null default (strftime('%s','now')),
  UNIQUE (`email`)
);

INSERT INTO users(id,email,password,name,status,email_notifications,created)
    SELECT id,email,password,name,status,email_notifications,created FROM users_old;

DROP TABLE `users_old`;

DROP TABLE IF EXISTS `confirmations`;
CREATE TABLE `confirmations` (
  `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` INT NOT NULL,
  `token` BLOB NOT NULL,
  `type` VARCHAR(32) NOT NULL DEFAULT '',
  `created` integer(4) not null default (strftime('%s','now')),
  UNIQUE (`token`)
);

COMMIT;
