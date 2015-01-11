DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
    `id` integer PRIMARY KEY,
    `title` varchar(64) NOT NULL DEFAULT '',
    UNIQUE(`title`)
);

DROP TABLE IF EXISTS `map_thread_tag`;
CREATE TABLE `map_thread_tag` (
    `thread_id` integer NOT NULL,
    `tag_id` integer NOT NULL,
    PRIMARY KEY(`thread_id`, `tag_id`)
);
