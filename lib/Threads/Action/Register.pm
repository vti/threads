package Threads::Action::Register;

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
    $validator->add_rule('email', 'NotDisposableEmail');

    return $validator;
}

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    if (Threads::DB::User->new(email => $params->{email})->load) {
        $validator->add_error(email => $self->loc('User exists'));
        return;
    }

    return 1;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my ($name) = split /\@/, $params->{email};

    if (Threads::DB::User->find(first => 1, where => [name => $name])) {
        $name = '';
    }

    my $user = Threads::DB::User->new(%$params, name => $name)->create;

    my $confirmation = Threads::DB::Confirmation->new(
        user_id => $user->get_column('id'),
        type    => 'register'
    )->create;

    my $email = $self->render(
        'email/confirmation_required',
        layout => undef,
        vars   => {
            email => $params->{email},
            token => to_hex $confirmation->get_column('token')
        }
    );

    $self->mailer->send(
        headers => [
            To      => $params->{email},
            Subject => $self->loc('Registration confirmation')
        ],
        body => $email
    );

    return $self->render('activation_needed',
        vars => {email => $params->{email}});
}

sub mailer {
    my $self = shift;

    return $self->service('mailer');
}

1;