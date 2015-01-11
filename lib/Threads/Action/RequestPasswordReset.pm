package Threads::Action::RequestPasswordReset;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Threads::DB::User;
use Threads::DB::Confirmation;
use Threads::Util qw(to_hex);

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

    my $user = Threads::DB::User->new(email => $params->{email})->load;

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

    Threads::DB::Confirmation->table->delete(
        where => [user_id => $user->get_column('id')]);

    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->get_column('id'),
        type    => 'reset_password'
    )->create;

    my $email = $self->render(
        'email/password_reset',
        layout => undef,
        vars   => {
            email => $params->{email},
            token => to_hex $confirmation->get_column('token')
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
