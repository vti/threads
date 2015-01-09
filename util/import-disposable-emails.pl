#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$RealBin';

BEGIN {
    unshift @INC, "$RealBin/../lib";
    unshift @INC, "$_/lib" for glob "$RealBin/../contrib/*";
}

use Tu::Config;
use Toks::DB;
use Toks::DB::DisposableEmailBlacklist;

my ($file) = @ARGV;
die 'Usage: <file>' unless $file && -f $file;

my $config =
  Tu::Config->new(mode => 1)->load("$RealBin/../config/config.yml");
Toks::DB->init_db(%{$config->{database}});

Toks::DB::DisposableEmailBlacklist->table->delete;

open my $fh, '<', $file or die $!;
while (defined (my $line = <$fh>)) {
    chomp $line;

    Toks::DB::DisposableEmailBlacklist->new(domain => $line)->create;
}

