#!/usr/bin/env perl

use strict;
use warnings;

use FindBin '$RealBin';

BEGIN {
    unshift @INC, "$RealBin/lib";
}

use Plack::Builder;
use Plack::App::File;
use Toks;

my $app = Toks->new;

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
