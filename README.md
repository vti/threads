# Threads

This is a modern fresh looking forum, primarily written for the russian Perl
magazine <http://pragmaticperl.com>.

## Live

Live English version can be found at <http://threads.showmetheco.de>.

## How to

How to start it locally.

1. Copy `config/config.yml.example` to `config/config.yml` and adjust to fit
   your needs.
2. Setup database

```
cat schema/*.sql | sqlite db.db
```

Or you can use a migration tool. See below.

3. Install dependencies

With `carton`:

```
carton install
```

With `cpanm`:

```
cpanm -L perl5 --installdeps .
```

4. Jobs

There are several jobs that need to be run periodically to keep the database
clean and notifications working.

Email notifications:

```
perl util/run-jog.pl send_email_notifications
```

Inactive registrations:

```
perl util/run-jog.pl cleanup_inactive_registrations
```

Other system stuff:

```
perl util/run-jog.pl cleanup_thread_views
```

5. Run

With `carton`:

```
carton exec -- plackup
```

With `local::lib` (if install with `cpanm`):

```
perl -Mlocal::lib=perl5 perl5/bin/plackup
```

6. Upgrading

After doing `git pull` you can notice new files in `schema` directory. You can
either manually run new migrations or use a migration tool. For example
[mimi](http://github.com/vti/app-mimi):

Setup migration table:

```
mimi setup --dsn 'dbi:SQLite:db.db'
```

Set latest migration (not needed if you used it from the start):

```
mimi set --dsn 'dbi:SQLite:db.db' <migration-number>
```
