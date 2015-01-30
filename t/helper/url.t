use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;
use TestLib;

use Threads::Helper::Url;

subtest 'returns url' => sub {
    my $helper = _build_helper();

    is($helper->root, '/');
};

subtest 'builds route' => sub {
    my $routes = _mock_routes();
    my $helper = _build_helper(routes => $routes);

    $helper->root(foo => 'bar');

    my ($name, %params) = $routes->mocked_call_args('build_path');
    is $name, 'root';
    is_deeply \%params, {foo => 'bar'};
};

subtest 'builds route without language when default' => sub {
    my $routes = _mock_routes();
    my $helper = _build_helper(
        routes => $routes,
        env    => {'tu.i18n.language' => 'en'}
    );

    my $url = $helper->root(foo => 'bar');

    is $url, '/';
};

subtest 'builds route with language' => sub {
    my $routes = _mock_routes();
    my $helper = _build_helper(
        routes => $routes,
        env    => {'plack.i18n.language' => 'ru'}
    );

    my $url = $helper->root(foo => 'bar');

    is $url, '/ru/';
};

sub _mock_i18n {
    my $i18n = Test::MonkeyMock->new;
    $i18n->mock(default_language => sub { 'en' });
    return $i18n;
}

sub _mock_routes {
    my $routes = Test::MonkeyMock->new;
    $routes->mock(build_path => sub { '/' });
    return $routes;
}

sub _build_helper {
    my (%params) = @_;

    $params{routes} ||= _mock_routes();
    $params{i18n}   ||= _mock_i18n();

    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { $params{$_[1]} });

    my $env = $params{env} || {};
    Threads::Helper::Url->new(env => $env, services => $services);
}

done_testing;
