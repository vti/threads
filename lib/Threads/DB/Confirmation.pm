package Threads::DB::Confirmation;

use strict;
use warnings;

use parent 'Threads::DB';

use Carp qw(croak);
use Threads::Util qw(gentoken from_hex);

__PACKAGE__->meta(
    table   => 'confirmations',
    columns => [
        qw/
          id
          user_id
          token
          type
          created
          /
    ],
    primary_key              => 'id',
    auto_increment           => 'id',
    unique_keys              => ['token'],
    generate_columns_methods => 1,
);

sub find_fresh_by_token {
    my $self = shift;
    my ($token, $type) = @_;

    croak 'token required' unless $token;
    croak 'type required'  unless $type;

    return Threads::DB::Confirmation->find(
        first => 1,
        where => [
            token   => from_hex $token,
            type    => $type,
            created => {'>=' => time - $self->_expiration_timeout}
        ]
    );
}

sub is_expired {
    my $self = shift;

    return $self->created < time - $self->_expiration_timeout;
}

sub find_by_token {
    my $self = shift;
    my ($token, $type) = @_;

    croak 'token required' unless $token;
    croak 'type required'  unless $type;

    return Threads::DB::Confirmation->find(
        first => 1,
        where => [
            token => from_hex $token,
            type  => $type,
        ]
    );
}

sub find_fresh_by_user_id {
    my $self = shift;
    my ($user_id, $type) = @_;

    croak 'user_id required' unless $user_id;
    croak 'type required'    unless $type;

    return Threads::DB::Confirmation->find(
        first => 1,
        where => [
            user_id => $user_id,
            type    => $type,
            created => {'>=' => time - 15 * 60}
        ]
    );
}

sub create {
    my $self = shift;

    if (!$self->token) {
        $self->token(gentoken(16));
    }

    return $self->SUPER::create;
}

sub _expiration_timeout { 45 * 60 }

1;
