package Threads::Action::Register;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Plack::Session;
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

    $validator->add_field('captcha') if $self->_has_captcha;

    return $validator;
}

sub show {
    my $self = shift;

    $self->_generate_captcha if $self->_has_captcha;

    return;
}

sub show_errors {
    my $self = shift;

    $self->_generate_captcha if $self->_has_captcha;

    return;
}

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    if (Threads::DB::User->new(email => $params->{email})->load) {
        $validator->add_error(email => $self->loc('User exists'));
        return;
    }

    if ($self->_has_captcha) {
        my $session         = Plack::Session->new($self->env);
        my $expected_answer = $session->get('captcha');

        if (!$expected_answer || $expected_answer ne $params->{captcha}) {
            $validator->add_error(captcha => $self->loc('Invalid captcha'));
            return;
        }
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

sub _has_captcha { shift->service('config')->{captcha} ? 1 : 0 }

sub _generate_captcha {
    my $self = shift;

    my $captchas = $self->service('config')->{captcha};

    my $captcha = $captchas->[int(rand(@$captchas))];

    my $session = Plack::Session->new($self->env);
    $session->set(captcha => $captcha->{answer});
    $self->set_var(captcha => {text => $captcha->{text}});
}

1;
