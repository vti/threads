package TestDB;

use strict;
use warnings;

use Threads::DB;

my %defaults = (
    User => {
        name     => 'foo',
        email    => 'foo@bar.com',
        password => 'silly',
        role     => 'user'
    }
);

sub build {
    my $class = shift;
    my ($name, %params) = @_;

    my $class_name = "Threads::DB::$name";
    return $class_name->new(%{$defaults{$name} || {}}, %params);
}

sub create {
    my $class = shift;

    return $class->build(@_)->create;
}

sub setup {
    my $self = shift;

    my $dbh = DBI->connect('dbi:SQLite::memory:', '', '', {RaiseError => 1});
    die $DBI::errorstr unless $dbh;

    $dbh->do("PRAGMA default_synchronous = OFF");
    $dbh->do("PRAGMA temp_store = MEMORY");

    my @schema_files = glob('schema/*.sql');

    my @schema;
    for my $file (@schema_files) {
        push @schema, split /;/, do {
            open my $fh, '<', $file or die $!;
            local $/;
            <$fh>;
        };
    }
    $dbh->do($_) for @schema;

    Threads::DB->init_db($dbh);
    Threads::DB->init_db->{sqlite_unicode} = 1;
}

1;
