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
    unique_keys    => ['email'],
    generate_columns_methods => 1,
);

sub load_auth {
    my $self = shift;
    my ($options) = @_;

    return
      unless my $nonce = Threads::DB::Nonce->new(id => $options->{id})->load;

    my $latest_nonce = Threads::DB::Nonce->find(
        first    => 1,
        where    => [user_id => $nonce->user_id],
        order_by => [id => 'DESC']
    );

    if (time - $nonce->created > 2 && $nonce->id ne $latest_nonce->id) {
        return;
    }

    my $user = $self->new(id => $nonce->user_id)->load;
    return unless $user && $user->status eq 'active';

    return $user;
}

sub finalize_auth {
    my $self = shift;
    my ($options) = @_;

    my $nonce = Threads::DB::Nonce->new(id => $options->{id})->load;

    if ($nonce) {
        Threads::DB::Nonce->table->delete(
            where => [
                user_id => $nonce->user_id,
                id      => {'!=' => $nonce->id},
                created => {'<' => time - 2}
            ]
        );

        if (time - $nonce->created > 2) {
            my $user_id = $nonce->user_id;
            $nonce->delete;

            my $new_nonce =
              Threads::DB::Nonce->new(user_id => $user_id)->create;
            $options->{id} = $new_nonce->id;
        }
    }

    return;
}

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
