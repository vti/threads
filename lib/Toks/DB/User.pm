package Toks::DB::User;

use strict;
use warnings;

use parent 'Toks::DB';

use Digest::MD5 ();

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

sub load_from_session {
    my $self = shift;
    my ($session) = @_;

    return unless $session->{user_id};
    return $self->find(first => 1, where => [id => $session->{user_id}]);
}

sub hash_password {
    my $self = shift;
    my ($password) = @_;

    return Digest::MD5::md5_hex($password || '');
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
