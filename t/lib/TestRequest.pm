package TestRequest;

use strict;
use warnings;

use Test::MonkeyMock;

use Tu::DispatchedRequest;

use HTTP::Request;
use HTTP::Message::PSGI qw(req_to_psgi);

sub to_env {
    my $class = shift;
    my (%params) = @_;

    my $env =
      req_to_psgi $params{req} ? $params{req} : HTTP::Request->new(GET => '/');

    $env->{'psgix.session'} ||= $params{'psgix.session'} || {};
    $env->{'psgix.session.options'} ||= {};
    $env->{'tu.displayer.vars'}     ||= $params{'tu.displayer.vars'} || {};
    $env->{'tu.auth'}               ||= $params{'tu.auth'};
    $env->{'tu.user'}               ||= $params{'tu.user'};
    $env->{'tu.dispatched_request'} ||=
      $params{'tu.dispatched_request'} || _build_dispatched_request(%params);

    return $env;
}

sub _build_dispatched_request {
    my (%params) = @_;

    my $dr = Tu::DispatchedRequest->new;
    $dr = Test::MonkeyMock->new($dr);
    $dr->mock(build_path => sub { '' });
    $dr->mock(captures   => sub { $params{captures} });

    return $dr;
}

1;
