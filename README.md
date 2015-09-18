# Threads

This is a modern fresh looking forum, primarily written for the Perl
magazine <http://forum.pragmaticperl.com> (in Russian).

## Live

Live English version can be found at <http://threads.showmetheco.de>.

## How to

How to start it locally.

### Configuration

Copy `config/config.yml.example` to `config/config.yml` and adjust to fit your needs.

### Database setup

```
cat schema/*.sql | sqlite db.db
```

Or you can use a migration tool. See below.

### Dependencies installation

1. Fetch submodules:

    ```
    git submodule update --init
    ```

2. Install modules from CPAN

    With `carton`:

    ```
    carton install
    ```

    With `cpanm`:

    ```
    cpanm -L perl5 --installdeps .
    ```

### Jobs

There are several jobs that need to be run periodically to keep the database
clean and notifications working.

Email notifications:

```
perl util/run-job.pl send_email_notifications
```

Inactive registrations:

```
perl util/run-job.pl cleanup_inactive_registrations
```

Other system stuff:

```
perl util/run-job.pl cleanup_thread_views
```

### Starting

With `carton`:

```
carton exec -- plackup
```

With `local::lib` (if install with `cpanm`):

```
perl -Mlocal::lib=perl5 perl5/bin/plackup
```

### Upgrading

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
