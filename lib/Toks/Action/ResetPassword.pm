package Toks::Action::ResetPassword;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::DB::User;
use Toks::DB::Confirmation;

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

    my $confirmation = Toks::DB::Confirmation->find(
        first => 1,
        where => [
            token => $token
        ]
    );

    $self->throw_not_found unless $confirmation;

    my $user =
      Toks::DB::User->new(id => $confirmation->get_column('user_id'))->load;

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

    $self->{confirmation}->delete;

    return $self->render('password_reset_success');
}

1;
