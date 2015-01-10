package Threads::DB::User;

use strict;
use warnings;

use parent 'Threads::DB';

use Encode ();
use Digest::MD5 ();
use Threads::DB::Nonce;

__PACKAGE__->meta(
    table   => 'users',
    columns => [
        qw/
          id
          email
          password
          name
          status
          created
          email_notifications
          notify_when_replied
          auto_subscribe
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    unique_keys    => ['email'],
);

sub role { 'user' }

sub load_auth {
    my $self = shift;
    my ($options) = @_;

    return unless my $nonce = Threads::DB::Nonce->new(id => $options->{id})->load;

    my $user = $self->new(id => $nonce->get_column('user_id'))->load;
    return unless $user && $user->get_column('status') eq 'active';

    $nonce->delete;

    my $new_nonce = Threads::DB::Nonce->new(user_id => $user->get_column('id'))->create;
    $options->{id} = $new_nonce->get_column('id');

    return $user;
}

sub hash_password {
    my $self = shift;
    my ($password) = @_;

    $password = Encode::encode('UTF-8', $password);

    $password = Digest::MD5::md5_hex($password || '');

    return Encode::decode('UTF-8', $password);
}

sub check_password {
    my $self = shift;
    my ($password) = @_;

    return $self->get_column('password') eq $self->hash_password($password);
}

sub create {
    my $self = shift;

    $self->set_column(
        password => $self->hash_password($self->get_column('password')));

    return $self->SUPER::create;
}

sub update_password {
    my $self = shift;
    my ($new_password) = @_;

    $self->set_column(password => $self->hash_password($new_password));

    return $self->save;
}

1;
