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
use Plack::I18N;
use Threads;
use Threads::DB::User;

my $app = Threads->new;

my $i18n = Plack::I18N->new(
    lexicon    => 'gettext',
    i18n_class => 'Threads::I18N',
    locale_dir => $app->service('home')->catfile('locale'),
    %{$app->service('config')->{i18n} || {}}
);
$app->services->register(i18n => $i18n);

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

        enable '+Tu::Middleware::Defaults',        services => $app->services;
        enable '+Tu::Middleware::Session::Cookie', services => $app->services;
        enable_if { $_[0]->{PATH_INFO} eq '/antibot.gif' } 'Antibot',
          filters => ['Static'];
        enable '+Tu::Middleware::Static',            services => $app->services;
        enable '+Tu::Middleware::RequestDispatcher', services => $app->services;
        enable 'I18N',                               i18n     => $i18n;

        enable sub {
            my $app = shift;

            sub {
                my ($env) = @_;

                my $handle = $env->{'plack.i18n.handle'};
                $env->{'tu.displayer.vars'}->{loc} =
                  sub { $handle->maketext(@_) };

                $app->($env);
            };
        };

        $ENV{PLACK_ENV} eq 'production'
          && enable_if { $_[0]->{PATH_INFO} eq '/register' } 'Antibot',
          filters => [
            'TooFast',
            'TooSlow',
            ['FakeField', field_name => 'website'],
            'Static',
            ['TextCaptcha', variants => $app->service('config')->{captcha}]
          ],
          fall_through => 1;

        enable '+Tu::Middleware::User',
          services    => $app->services,
          user_loader => Threads::DB::User->new;
        enable '+Tu::Middleware::ACL',              services => $app->services;
        enable '+Tu::Middleware::ActionDispatcher', services => $app->services;
        enable '+Tu::Middleware::ViewDisplayer',    services => $app->services;

        $app->to_app;
    };
}
