package Threads::Origin;

use strict;
use warnings;

use URI;
use Plack::Session;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{env}      = $params{env};
    $self->{services} = $params{services};
    $self->{user}     = $params{user};

    return $self;
}

sub env      { $_[0]->{env} }
sub services { $_[0]->{services} }
sub user     { $_[0]->{user} }

sub origin {
    my $self = shift;

    my $session = Plack::Session->new($self->env);
    return unless my $origin = $session->get('origin');
    return unless ref $origin eq 'ARRAY' && @$origin > 1;

    $origin = $origin->[1];
    return unless ref $origin eq 'HASH';

    return unless my $url    = $origin->{url};
    return unless my $action = $origin->{action};

    if (my $user = $self->user) {
        my $acl = $self->services->service('acl');
        return unless $acl->is_allowed($user->role, $action);
    }

    return URI->new($origin->{url});
}

1;
