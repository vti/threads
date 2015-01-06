package Toks::Action::ConfirmDeregistration;

use strict;
use warnings;

use parent 'Tu::Action';

use Toks::DB::User;
use Toks::DB::Confirmation;

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

    $user->delete;

    $confirmation->delete;

    return $self->render('deregistration_confirmation_success');
}

1;
