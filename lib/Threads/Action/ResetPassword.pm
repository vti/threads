package Threads::Action::ResetPassword;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Threads::DB::User;
use Threads::DB::Confirmation;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('new_password');
    $validator->add_field('new_password_confirmation');

    $validator->add_group_rule('new_password',
        [qw/new_password new_password_confirmation/], 'compare');

    return $validator;
}

sub run {
    my $self = shift;

    my $token = $self->captures->{token};
    $self->throw_not_found unless $token;

    my $confirmation =
      Threads::DB::Confirmation->find_fresh_by_token($token, 'reset_password');
    $self->throw_not_found unless $confirmation;

    my $user =
      Threads::DB::User->new(id => $confirmation->get_column('user_id'))->load;

    $self->throw_not_found unless $user;

    $self->{confirmation} = $confirmation;
    $self->{user}         = $user;

    return $self->SUPER::run;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->{user};

    $user->update_password($params->{new_password});

    Threads::DB::Confirmation->table->delete(
        where => [user_id => $user->id, type => 'reset_password']);

    return $self->render('password_reset_success');
}

1;
