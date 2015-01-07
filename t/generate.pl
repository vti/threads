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
use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Reply;

my $config = Tu::Config->new(mode => 1)->load('config/config.yml');
Toks::DB->init_db(%{$config->{database}});

Toks::DB::User->table->delete;
Toks::DB::Thread->table->delete;
Toks::DB::Reply->table->delete;

Toks::DB::User->new(
    email    => 'foo@bar.com',
    password => 'password',
    status   => 'active'
)->create;

Toks::DB::User->new(
    email    => 'foo2@bar.com',
    password => 'password',
    status   => 'active'
)->create;
