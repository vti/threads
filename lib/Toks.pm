package Toks;

use strict;
use warnings;

use parent 'Tu';

our $VERSION = '0.01';

use Toks::DB::User;

sub startup {
    my $self = shift;

    $self->register_plugin('CommonServices');
    $self->register_plugin('CommonMiddleware');

    $self->register_plugin('ACL', user_loader => Toks::DB::User->new);
    $self->register_plugin('ObjectDB');
    $self->register_plugin('Mailer');
    $self->register_plugin('I18N');

    $self->_add_routes;
    $self->_add_acl;

    return $self;
}

sub _add_routes {
    my $self = shift;

    my $routes = $self->service('routes');

    $routes->add_route(
        '/',
        name   => 'index',
        method => 'GET'
    );

    $routes->add_route('/register', name => 'register');

    $routes->add_route(
        '/confirm-registration/:token',
        name   => 'confirm_registration',
        method => 'GET'
    );

    $routes->add_route('/deregister', name => 'deregister');

    $routes->add_route(
        '/confirm-deregistration/:token',
        name   => 'confirm_deregistration',
        method => 'GET'
    );

    $routes->add_route('/login', name => 'login');

    $routes->add_route('/settings',        name => 'settings');
    $routes->add_route('/change-password', name => 'change_password');

    $routes->add_route('/request-password-reset',
        name => 'request_password_reset');

    $routes->add_route('/reset-password/:token', name => 'reset_password');

    $routes->add_route('/logout', name => 'logout');

    $routes->add_route('/not_found', name => 'not_found');

    $routes->add_route('/forbidden', name => 'forbidden');

    $routes->add_route('/create_thread', name => 'create_thread');
    $routes->add_route(
        '/threads/(:id)-(:slug)',
        name        => 'view_thread',
        constraints => {id => qr/\d+/}
    );
    $routes->add_route('/threads/:id/update', name => 'update_thread');
    $routes->add_route(
        '/threads/:id/delete',
        name   => 'delete_thread',
        method => 'POST'
    );
    $routes->add_route(
        '/threads/:id/toggle-subscription',
        name   => 'toggle_subscription',
        method => 'POST'
    );

    $routes->add_route(
        '/threads/:id/reply',
        name   => 'create_reply',
        method => 'POST'
    );
    $routes->add_route(
        '/replies/:id/update',
        name   => 'update_reply',
        method => 'POST'
    );
    $routes->add_route(
        '/replies/:id/delete',
        name   => 'delete_reply',
        method => 'POST'
    );
    $routes->add_route(
        '/replies/:id/thank',
        name   => 'thank_reply',
        method => 'POST'
    );

    $routes->add_route(
        '/delete-subscriptions',
        name   => 'delete_subscriptions',
    );
    $routes->add_route(
        '/subscriptions',
        name   => 'list_subscriptions',
    );

    $routes->add_route(
        '/notifications',
        name   => 'list_notifications',
    );
    $routes->add_route(
        '/delete-notifications',
        name   => 'delete_notifications',
    );
}

sub _add_acl {
    my $self = shift;

    my $acl = $self->service('acl');

    $acl->add_role('anonymous');
    $acl->add_role('user');

    $acl->allow('anonymous', 'index');
    $acl->allow('anonymous', 'register');
    $acl->allow('anonymous', 'confirm_registration');
    $acl->allow('anonymous', 'request_password_reset');
    $acl->allow('anonymous', 'reset_password');
    $acl->allow('anonymous', 'login');
    $acl->allow('anonymous', 'view_thread');
    $acl->allow('anonymous', 'not_found');
    $acl->allow('anonymous', 'forbidden');
    $acl->allow('user',      '*');

    $acl->deny('user', 'login');
    $acl->deny('user', 'register');
}

1;
