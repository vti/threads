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

    $validator->add_field('name');
    $validator->add_field('email');
    $validator->add_field('password');

    $validator->add_rule('name', 'Regexp', qr/^[a-z0-9-_]+$/i);
    $validator->add_rule('name', 'MaxLength', 32);
    $validator->add_rule('email', 'Email');
    $validator->add_rule('email', 'NotDisposableEmail');

    return $validator;
}

sub show        {}
sub show_errors {}

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    if ($self->env->{'plack.antibot.detected'}) {
        if ($self->env->{'plack.antibot.textcaptcha.detected'}) {
            $validator->add_error(
                $self->env->{'plack.antibot.textcaptcha.field_name'} =>
                  $self->loc('Invalid captcha'));
            return;
        }

        $validator->add_error(email => $self->loc('Suspicious activity'));
        return;
    }

    if (Threads::DB::User->new(name => $params->{name})->load) {
        $validator->add_error(name => $self->loc('User exists'));
        return;
    }

    if (Threads::DB::User->new(email => $params->{email})->load) {
        $validator->add_error(email => $self->loc('User exists'));
        return;
    }

    return 1;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = Threads::DB::User->new(%$params)->create;

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

    return $self->render('activation_needed',
        vars => {email => $params->{email}});
}

sub mailer {
    my $self = shift;

    return $self->service('mailer');
}

1;
