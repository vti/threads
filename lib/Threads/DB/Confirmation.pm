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
    primary_key    => 'id',
    auto_increment => 'id',
    unique_keys    => ['token'],
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

1;
