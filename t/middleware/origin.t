use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;
use TestLib;
use TestRequest;

use HTTP::Request::Common;
use Threads::Middleware::Origin;

subtest 'do nothing when no dispatched request' => sub {
    my $mw = _build_middleware();

    my $env = TestRequest->to_env(req => GET '/');
    $mw->call($env);

    is_deeply $env->{'psgix.session'}, {};
};

subtest 'save current url' => sub {
    my $mw = _build_middleware();

    my $dispatched_request = _mock_dispatched_request(action => 'index');
    my $env = TestRequest->to_env(
        req                     => GET('/'),
        'tu.dispatched_request' => $dispatched_request
    );
    $mw->call($env);

    is_deeply $env->{'psgix.session'},
      {origin => [{url => '/', action => 'index'}]};
};

subtest 'do not save same url' => sub {
    my $mw = _build_middleware();

    my $dispatched_request = _mock_dispatched_request(action => 'index');
    my $env = TestRequest->to_env(
        req                     => GET('/'),
        'tu.dispatched_request' => $dispatched_request
    );
    $mw->call($env);
    $mw->call($env);

    is_deeply $env->{'psgix.session'},
      {origin => [{url => '/', action => 'index'}]};
};

subtest 'unshifts origin' => sub {
    my $mw = _build_middleware();

    my $session = {};

    {
        my $dispatched_request = _mock_dispatched_request(action => 'index');
        my $env = TestRequest->to_env(
            req                     => GET('/'),
            'tu.dispatched_request' => $dispatched_request
        );
        $mw->call($env);
        $session = $env->{'psgix.session'};
    }

    {
        my $dispatched_request = _mock_dispatched_request(action => 'foo');
        my $env = TestRequest->to_env(
            req                     => GET('/foo'),
            'psgix.session'         => $session,
            'tu.dispatched_request' => $dispatched_request
        );
        $mw->call($env);
        $session = $env->{'psgix.session'};
    }

    is_deeply $session->{origin},
      [{url => '/foo', action => 'foo'}, {url => '/', action => 'index'}];
};

subtest 'keeps only two last origins' => sub {
    my $mw = _build_middleware();

    my $session = {};

    {
        my $dispatched_request = _mock_dispatched_request(action => 'index');
        my $env = TestRequest->to_env(
            req                     => GET('/'),
            'tu.dispatched_request' => $dispatched_request
        );
        $mw->call($env);
        $session = $env->{'psgix.session'};
    }

    {
        my $dispatched_request = _mock_dispatched_request(action => 'foo');
        my $env = TestRequest->to_env(
            req                     => GET('/foo'),
            'psgix.session'         => $session,
            'tu.dispatched_request' => $dispatched_request
        );
        $mw->call($env);
        $session = $env->{'psgix.session'};
    }

    {
        my $dispatched_request = _mock_dispatched_request(action => 'bar');
        my $env = TestRequest->to_env(
            req                     => GET('/bar'),
            'psgix.session'         => $session,
            'tu.dispatched_request' => $dispatched_request
        );
        $mw->call($env);
        $session = $env->{'psgix.session'};
    }

    is_deeply $session->{origin},
      [{url => '/bar', action => 'bar'}, {url => '/foo', action => 'foo'}];
};

sub _mock_dispatched_request {
    my (%params) = @_;

    my $mock = Test::MonkeyMock->new;
    $mock->mock(action => sub { $params{action} });
    return $mock;
}

sub _build_middleware {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    return Threads::Middleware::Origin->new(app => sub { });
}

done_testing;
