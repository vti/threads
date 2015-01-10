#!/usr/bin/env perl

use strict;
use warnings;

use FindBin '$RealBin';

BEGIN {
    unshift @INC, "$RealBin/lib";
    unshift @INC, "$_/lib" for glob "$RealBin/contrib/*";
}

use Plack::Builder;
use Plack::App::File;
use Threads;

my $app = Threads->new;

builder {
    mount '/favicon.ico' =>
      Plack::App::File->new(file => $app->service('home')->catfile('public/favicon.ico'))
      ->to_app;

    mount '/' => builder {
        enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
        "Plack::Middleware::ReverseProxy";

        $app->to_app;
    };
}
