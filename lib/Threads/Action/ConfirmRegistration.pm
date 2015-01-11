package Threads::Action::ConfirmRegistration;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::User;
use Threads::DB::Confirmation;

sub run {
    my $self = shift;

    my $token = $self->captures->{token};
    $self->throw_not_found unless $token;

    $self->throw_not_found
      unless my $confirmation =
      Threads::DB::Confirmation->find_fresh_by_token($token, 'register');

    $self->throw_not_found
      unless my $user =
      Threads::DB::User->new(id => $confirmation->get_column('user_id'))->load;

    $user->set_column(status => 'active');
    $user->save;

    $confirmation->delete;

    return $self->render('activation_success');
}

1;
