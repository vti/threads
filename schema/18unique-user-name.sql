update users set name = id where name = '';
create unique index name on users(`name`);
