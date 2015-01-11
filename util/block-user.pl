#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$RealBin';

binmode STDOUT, ':utf8';

BEGIN {
    unshift @INC, "$RealBin/../lib";
    unshift @INC, "$_/lib" for glob "$RealBin/../contrib/*";
}

use Getopt::Long;
use Encode ();
use Tu::Config;
use Threads::DB;
use Threads::DB::User;

my $verbose;
my $unblock;
GetOptions('unblock' => \$unblock, 'verbose' => \$verbose)
  or die("Error in command line arguments\n");

my ($id) = map { Encode::decode('UTF-8', $_) } @ARGV;
die 'Usage: <id|email|name>' unless $id;

my $config = Tu::Config->new(mode => 1)->load("$RealBin/../config/config.yml");
Threads::DB->init_db(%{$config->{database}});

my $user = Threads::DB::User->find(
    first => 1,
    where => [
        $id =~ m/^\d+$/
        ? (id => $id)
        : ($id =~ m/\@/ ? (email => $id) : (name => $id))
    ]
);

die 'Unknown user' unless $user;

$user->status($unblock ? 'active' : 'blocked');
$user->update;

if ($verbose) {
    print sprintf "User id=%d email=%s name=%s %s\n",
      $user->id,
      $user->email,
      $user->name,
      $unblock ? 'unblocked' : 'blocked';
}

