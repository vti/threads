package Threads::DB::User;

use strict;
use warnings;

use parent 'Threads::DB';

use Encode ();
use Carp qw(croak);
use Digest::SHA ();
use Threads::DB::Nonce;
use Threads::Util qw(gentoken);

__PACKAGE__->meta(
    table   => 'users',
    columns => [
        qw/
          id
          email
          password
          salt
          name
          status
          created
          email_notifications
          role
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    unique_keys    => ['name', 'email'],
    generate_columns_methods => 1,
);

sub hash_password {
    my $self = shift;
    my ($password, $salt) = @_;

    croak 'password required' unless defined $password;
    croak 'salt required'     unless defined $salt;

    $password = Encode::encode('UTF-8', $password);

    $password = Digest::SHA::sha256_hex($password . $salt);

    return Encode::decode('UTF-8', $password);
}

sub check_password {
    my $self = shift;
    my ($password) = @_;

    my $salt = $self->salt;

    return $self->password eq
      $self->hash_password($password, $salt);
}

sub create {
    my $self = shift;

    my $salt = gentoken(64);
    my $hashed_password = $self->hash_password($self->password, $salt);

    $self->password($hashed_password);
    $self->salt($salt);

    return $self->SUPER::create;
}

sub update_password {
    my $self = shift;
    my ($new_password) = @_;

    my $salt = gentoken(64);
    $self->password($self->hash_password($new_password, $salt));
    $self->salt($salt);

    return $self->save;
}

1;
