use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Threads::Origin;

subtest 'return undef when no session' => sub {
    my $origin = _build_origin(env => {'psgix.session' => {}});

    ok !defined $origin->origin;
};

subtest 'return undef when origin invalid' => sub {
    my $origin = _build_origin(env => {'psgix.session' => {origin => 1}});

    ok !defined $origin->origin;
};

subtest 'return undef when origin not enough' => sub {
    my $origin = _build_origin(env => {'psgix.session' => {origin => ['foo']}});

    ok !defined $origin->origin;
};

subtest 'return undef when origin not hash' => sub {
    my $origin =
      _build_origin(env => {'psgix.session' => {origin => ['foo', 'bar']}});

    ok !defined $origin->origin;
};

subtest 'return undef when origin empty' => sub {
    my $origin =
      _build_origin(env => {'psgix.session' => {origin => [{}, {}]}});

    ok !defined $origin->origin;
};

subtest 'return url' => sub {
    my $origin = _build_origin(
        env => {
            'psgix.session' => {origin => [{}, {url => '/', action => 'index'}]}
        }
    );

    isa_ok $origin->origin, 'URI';
};

subtest 'return undef when not allowed for user' => sub {
    my $origin = _build_origin(
        env => {
            'psgix.session' => {origin => [{}, {url => '/', action => 'index'}]}
        },
        services => _mock_services(),
        user     => _mock_user()
    );

    ok !defined $origin->origin;
};

subtest 'return uri when allowed' => sub {
    my $origin = _build_origin(
        env => {
            'psgix.session' => {origin => [{}, {url => '/', action => 'index'}]}
        },
        services => _mock_services(acl => _mock_acl(is_allowed => 1)),
        user     => _mock_user()
    );

    isa_ok $origin->origin, 'URI';
};

sub _mock_user {
    my (%params) = @_;

    my $user = Test::MonkeyMock->new;
    $user->mock(role => sub { 'role' });
    return $user;
}

sub _mock_acl {
    my (%params) = @_;

    my $acl = Test::MonkeyMock->new;
    $acl->mock(is_allowed => sub { $params{is_allowed} });
    return $acl;
}

sub _mock_services {
    my (%params) = @_;

    my $acl = $params{acl} || _mock_acl();

    my $mock = Test::MonkeyMock->new;
    $mock->mock(service => sub { $acl });
    return $mock;
}

sub _build_origin {
    Threads::Origin->new(services => _mock_services(), @_);
}

done_testing;
