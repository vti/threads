package Toks::Helper::User;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::User;

sub display_name {
    my $self = shift;
    my ($user) = @_;

    return '' unless $user;

    return $user->{name} if $user->{name};

    return 'User' . $user->{id};
}

sub count {
    my $self = shift;
    my (%params) = @_;

    return Toks::DB::User->table->count(where => [status => 'active']);
}

1;
