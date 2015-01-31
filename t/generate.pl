#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use FindBin '$RealBin';

BEGIN {
    unshift @INC, "$RealBin/../lib";
    unshift @INC, "$_/lib" for glob "$RealBin/../contrib/*";

    $ENV{PLACK_ENV} = 'development';
}

use Plack::Builder;
use Tu::Config;
use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Reply;

my $config = Tu::Config->new(mode => 1)->load('config/config.yml');
Threads::DB->init_db(%{$config->{database}});

Threads::DB::User->table->delete;
Threads::DB::Thread->table->delete;
Threads::DB::Reply->table->delete;

Threads::DB::User->new(
    name     => 'foo',
    email    => 'foo@bar.com',
    password => 'password',
    status   => 'active'
)->create;

Threads::DB::User->new(
    name     => 'foo2',
    email    => 'foo2@bar.com',
    password => 'password',
    status   => 'active'
)->create;
