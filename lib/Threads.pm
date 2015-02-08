package Threads;

use strict;
use warnings;

use parent 'Tu';

our $VERSION = '0.01';

use Plack::I18N;
use Threads::DB::User;

sub startup {
    my $self = shift;

    my $services = $self->services;

    $services->register_group('Tu::ServiceContainer::Common',
        action_factory => 'Tu::ActionFactory');

    $self->services->register(acl => 'Tu::ACL', new => 1);

    $services->register_group('Tu::ServiceContainer::Mailer');

    Threads::DB->init_db(%{$self->service('config')->{database}});

    my $i18n = Plack::I18N->new(
        lexicon    => 'gettext',
        i18n_class => 'Threads::I18N',
        locale_dir => $self->service('home')->catfile('locale'),
        %{$self->service('config')->{i18n} || {}}
    );
    $services->register(i18n => $i18n);

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

    $routes->add_route('/register', name => 'register',);

    $routes->add_route(
        '/confirm-registration/:token',
        name   => 'confirm_registration',
        method => 'GET'
    );

    $routes->add_route(
        '/resend-registration-confirmation',
        name => 'resend_registration_confirmation'
    );
    $routes->add_route(
        '/resend-registration-confirmation-success',
        name => 'resend_registration_confirmation_success',
    );

    $routes->add_route('/deregister', name => 'deregister');

    $routes->add_route(
        '/confirm-deregistration/:token',
        name   => 'confirm_deregistration',
        method => 'GET'
    );

    $routes->add_route('/login', name => 'login');

    $routes->add_route('/settings',        name => 'settings');
    $routes->add_route('/profile',         name => 'profile');
    $routes->add_route('/change-password', name => 'change_password');

    $routes->add_route('/request-password-reset',
        name => 'request_password_reset');

    $routes->add_route('/reset-password/:token', name => 'reset_password');

    $routes->add_route('/logout', name => 'logout', method => 'POST');

    $routes->add_route('/not_found', name => 'not_found');

    $routes->add_route('/forbidden', name => 'forbidden');

    $routes->add_route('/preview', name => 'preview', method => 'POST');

    $routes->add_route('/threads.rss', name => 'threads_rss');
    $routes->add_route('/create-thread', name => 'create_thread');
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
    $routes->add_route('/tags/autocomplete', name => 'autocomplete_tags');
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
        '/replies/:id/report',
        name   => 'toggle_report',
        method => 'POST'
    );
    $routes->add_route(
        '/replies/:id/read',
        name   => 'read_reply',
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

    $routes->add_route(
        '/admin',
        name   => 'admin_index',
    );

    $routes->add_route(
        '/admin/users',
        name   => 'admin_list_users',
    );

    $routes->add_route(
        '/admin/users/:id/toggle-blocked',
        name   => 'admin_toggle_blocked',
        method => 'POST'
    );
}

sub _add_acl {
    my $self = shift;

    my $acl = $self->service('acl');

    $acl->add_role('anonymous');
    $acl->add_role('user');

    $acl->allow('anonymous', 'index');
    $acl->allow('anonymous', 'threads_rss');
    $acl->allow('anonymous', 'register');
    $acl->allow('anonymous', 'confirm_registration');
    $acl->allow('anonymous', 'resend_registration_confirmation');
    $acl->allow('anonymous', 'resend_registration_confirmation_success');
    $acl->allow('anonymous', 'request_password_reset');
    $acl->allow('anonymous', 'reset_password');
    $acl->allow('anonymous', 'login');
    $acl->allow('anonymous', 'view_thread');
    $acl->allow('anonymous', 'not_found');
    $acl->allow('anonymous', 'forbidden');
    $acl->allow('user',      '*');

    $acl->deny('user', 'login');
    $acl->deny('user', 'register');
    $acl->deny('user', 'confirm_registration');
    $acl->deny('user', 'resend_registration_confirmation');
    $acl->deny('user', 'resend_registration_confirmation_success');
    $acl->deny('user', 'request_password_reset');
    $acl->deny('user', 'reset_password');

    $acl->add_role('admin', 'user');
    $acl->deny('user', qr/^admin_/);
}

1;
