DROP TABLE IF EXISTS `nonces`;
CREATE TABLE `nonces` (
  `id` INTEGER NOT NULL PRIMARY KEY,
  `user_id` INTEGER NOT NULL,
  `created` integer(4) not null default (strftime('%s','now'))
);
