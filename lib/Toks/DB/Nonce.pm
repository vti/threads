package Toks::DB::Nonce;

use strict;
use warnings;

use parent 'Toks::DB';

use Time::HiRes qw(time);

__PACKAGE__->meta(
    table   => 'nonces',
    columns => [
        qw/
          id
          user_id
          created
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
);

sub create {
    my $self = shift;

    $self->set_column(id => $self->_generate_id);

    return $self->SUPER::create;
}

sub _generate_id {
    my $class = shift;

    my $id = sprintf '%.04f', time - 1396607860;

    $id =~ s{\.}{};

    return $id;
}

1;
