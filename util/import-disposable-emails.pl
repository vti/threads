#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$RealBin';

BEGIN {
    unshift @INC, "$RealBin/../lib";
    unshift @INC, "$_/lib" for glob "$RealBin/../contrib/*";
}

use Tu::Config;
use Threads::DB;
use Threads::DB::DisposableEmailBlacklist;

my ($file) = @ARGV;
die 'Usage: <file>' unless $file && -f $file;

my $config =
  Tu::Config->new(mode => 1)->load("$RealBin/../config/config.yml");
Threads::DB->init_db(%{$config->{database}});

Threads::DB::DisposableEmailBlacklist->table->delete;

open my $fh, '<', $file or die $!;
while (defined (my $line = <$fh>)) {
    chomp $line;

    Threads::DB::DisposableEmailBlacklist->new(domain => $line)->create;
}

