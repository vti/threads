package Toks::Action::RequestPasswordReset;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::DB::User;
use Toks::DB::Confirmation;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('email');
    $validator->add_rule('email', 'Email');

    return $validator;
}

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    my $user = Toks::DB::User->new(email => $params->{email})->load;

    if (!$user) {
        $validator->add_error(email => $self->loc('User does not exist'));
        return;
    }

    if ($user->get_column('status') ne 'active') {
        $validator->add_error(email => $self->loc('Account not activated'));
        return;
    }

    $self->{user} = $user;

    return 1;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->{user};

    my $confirmation =
      Toks::DB::Confirmation->new(user_id => $user->get_column('id'))->create;

    my $email = $self->render(
        'email/password_reset',
        layout => undef,
        vars   => {
            email => $params->{email},
            token => $confirmation->get_column('token')
        }
    );

    $self->mailer->send(
        headers => [
            To      => $params->{email},
            Subject => $self->loc('Password reset')
        ],
        body => $email
    );

    return $self->render(
        'password_reset_confirmation_needed',
        vars => {email => $params->{email}}
    );
}

sub mailer {
    my $self = shift;

    return $self->service('mailer');
}

1;
