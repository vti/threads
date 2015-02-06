#!/usr/bin/env perl

use strict;
use warnings;

use Plack::Builder;

builder {
    enable 'Static', path => qr{^/js}, root => '../public/';
    enable 'Static', path => qr/\.(?:js|css|html)$/, root => '.';
    sub {
        my $env = shift;

        return [302, [Location => '/suite.html'], []];
    };
};
