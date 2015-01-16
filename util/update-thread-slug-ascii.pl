#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$RealBin';

binmode STDOUT, ':utf8';

BEGIN {
    unshift @INC, "$RealBin/../lib";
    unshift @INC, "$_/lib" for glob "$RealBin/../contrib/*";
}

use Text::Unidecode ();
use Tu::Config;
use Threads::DB;
use Threads::DB::Thread;

my $config = Tu::Config->new(mode => 1)->load("$RealBin/../config/config.yml");
Threads::DB->init_db(%{$config->{database}});

my @threads = Threads::DB::Thread->find;
foreach my $thread (@threads) {
    $thread->slug_ascii(Text::Unidecode::unidecode($thread->slug));
    $thread->update;
}
