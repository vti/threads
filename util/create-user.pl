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
use Threads::DB::User;

my ($email, $password) = @ARGV;
die 'Usage: <email> <password>' unless $email && $password;

my $config = Tu::Config->new(mode => 1)->load("$RealBin/../config/config.yml");
Threads::DB->init_db(%{$config->{database}});

Threads::DB::User->new(
    email    => $email,
    password => $password,
    status   => 'active'
)->create;
