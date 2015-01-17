package Threads::Action::ResendRegistrationConfirmation;

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
    $validator->add_field('password');

    $validator->add_rule('email', 'Email');

    return $validator;
}

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    my $user = Threads::DB::User->new(email => $params->{email})->load;

    if (!$user) {
        $validator->add_error(email => $self->loc('Unknown credentials'));
        return;
    }

    if (!$user->check_password($params->{password})) {
        $validator->add_error(email => $self->loc('Unknown credentials'));
        return;
    }

    if ($user->status ne 'new') {
        $validator->add_error(
            email => $self->loc('Account does not need activation'));
        return;
    }

    if (Threads::DB::Confirmation->find_fresh_by_user_id($user->id, 'register'))
    {
        $validator->add_error(
            email => $self->loc('Old confirmation not expired. Try later'));
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
        where => [user_id => $user->id, type => 'register']);

    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->id,
        type    => 'register'
    )->create;

    my $email = $self->render(
        'email/confirmation_required',
        layout => undef,
        vars   => {
            email => $params->{email},
            token => to_hex $confirmation->token
        }
    );

    $self->mailer->send(
        headers => [
            To      => $params->{email},
            Subject => $self->loc('Registration confirmation')
        ],
        body => $email
    );

    return $self->redirect('resend_registration_confirmation_success');
}

sub mailer {
    my $self = shift;

    return $self->service('mailer');
}

1;
