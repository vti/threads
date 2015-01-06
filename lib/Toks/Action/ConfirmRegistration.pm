package Toks::Action::ConfirmRegistration;

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

    $user->set_column(status => 'active');
    $user->save;

    $confirmation->delete;

    return $self->render('activation_success');
}

1;
