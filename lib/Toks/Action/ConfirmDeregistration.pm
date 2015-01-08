package Toks::Action::ConfirmDeregistration;

use strict;
use warnings;

use parent 'Tu::Action';

use Plack::Session;
use Toks::DB::User;
use Toks::DB::Confirmation;
use Toks::DB::Notification;
use Toks::DB::Subscription;

sub run {
    my $self = shift;

    my $token = $self->captures->{token};
    $self->throw_not_found unless $token;

    $self->throw_not_found
      unless my $confirmation =
      Toks::DB::Confirmation->new(token => $token)->load;

    $self->throw_not_found
      unless my $user =
      Toks::DB::User->new(id => $confirmation->get_column('user_id'))->load;

    $user->set_columns(
        email    => $user->get_column('id'),
        name     => '',
        password => '',
        status   => 'deleted'
    );
    $user->update;

    my $session = Plack::Session->new($self->env);
    $session->expire;

    $confirmation->delete;

    Toks::DB::Notification->table->delete(
        where => [user_id => $user->get_column('id')]);
    Toks::DB::Subscription->table->delete(
        where => [user_id => $user->get_column('id')]);

    return $self->render('deregistration_confirmation_success');
}

1;
