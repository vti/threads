package Threads::Helper::Acl;

use strict;
use warnings;

use parent 'Tu::Helper';

use Threads::ObjectACL;

sub user {
    my $self = shift;

    my $user = $self->scope->user;
    return {} unless $user;

    return $user->to_hash;
}

sub is_anon {
    my $self = shift;

    my $user = $self->scope->user;
    return $user ? 0 : 1;
}

sub is_user {
    my $self = shift;

    my $user = $self->scope->user;
    return $user ? 1 : 0;
}

sub is_admin {
    my $self = shift;

    my $user = $self->scope->user;
    return 0 unless $user && $user->role eq 'admin';

    return 1;
}

sub is_author {
    my $self = shift;
    my ($object) = @_;

    my $user = $self->scope->user;

    return Threads::ObjectACL->new->is_author($user, $object);
}

sub is_allowed {
    my $self = shift;
    my ($object, $action) = @_;

    my $user = $self->scope->user;

    return Threads::ObjectACL->new->is_allowed($user, $object, $action);
}

1;
