package Threads::Helper::User;

use strict;
use warnings;

use parent 'Tu::Helper';

use Threads::DB::User;

sub display_name {
    my $self = shift;
    my ($user) = @_;

    return '' unless $user;

    return '<strike>deleted</strike>' if $user->{status} eq 'deleted';

    return $user->{name};
}

sub count {
    my $self = shift;
    my (%params) = @_;

    return Threads::DB::User->table->count(where => [status => 'active']);
}

1;
