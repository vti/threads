package Toks::DB::Confirmation;

use strict;
use warnings;

use parent 'Toks::DB';

use Digest::MD5 ();

__PACKAGE__->meta(
    table   => 'confirmations',
    columns => [
        qw/
          id
          user_id
          token
          created
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    unique_keys    => ['token'],
);

sub create {
    my $self = shift;

    if (!$self->get_column('token')) {
        my $token = $self->generate_token;

        $self->set_column(token => $token);
    }

    return $self->SUPER::create;
}

sub generate_token {
    my $self = shift;

    my $token = time . rand(100);

    return Digest::MD5::md5_hex($token);
}

1;
