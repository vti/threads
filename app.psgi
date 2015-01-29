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
use Threads::DB::User;

my $app = Threads->new;

builder {
    mount '/favicon.ico' => Plack::App::File->new(
        file => $app->service('home')->catfile('public/favicon.ico'))->to_app;

    mount '/' => builder {
        enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
        'Plack::Middleware::ReverseProxy';

        enable
          'ErrorDocument',
          403        => '/forbidden',
          404        => '/not_found',
          subrequest => 1;

        enable 'HTTPExceptions';

        enable '+Tu::Middleware::Defaults',          services => $app->services;
        enable '+Tu::Middleware::Static',            services => $app->services;
        enable '+Tu::Middleware::Session::Cookie',   services => $app->services;
        enable '+Tu::Middleware::RequestDispatcher', services => $app->services;
        enable '+Tu::Middleware::I18N',              services => $app->services;
        enable '+Tu::Middleware::User',
          services    => $app->services,
          user_loader => Threads::DB::User->new;
        enable '+Tu::Middleware::ACL',              services => $app->services;
        enable '+Tu::Middleware::ActionDispatcher', services => $app->services;
        enable '+Tu::Middleware::ViewDisplayer',    services => $app->services;

        $app->to_app;
    };
}
