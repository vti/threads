package Threads::Action::ConfirmDeregistration;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::User;
use Threads::DB::Confirmation;
use Threads::DB::Notification;
use Threads::DB::Subscription;

sub run {
    my $self = shift;

    my $token = $self->captures->{token};
    $self->throw_not_found unless $token;

    $self->throw_not_found
      unless my $confirmation =
      Threads::DB::Confirmation->find_fresh_by_token($token, 'deregister');

    $self->throw_not_found
      unless my $user =
      Threads::DB::User->new(id => $confirmation->user_id)->load;

    $user->set_columns(
        email    => '#' . $user->id,
        name     => '#' . $user->id,
        password => '',
        status   => 'deleted'
    );
    $user->update;

    $self->scope->auth->logout;

    $confirmation->delete;

    Threads::DB::Notification->table->delete(
        where => [user_id => $user->id]);
    Threads::DB::Subscription->table->delete(
        where => [user_id => $user->id]);

    return $self->render('deregistration_confirmation_success');
}

1;
