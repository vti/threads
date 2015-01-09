package Toks::Action::Login;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::DB::User;
use Toks::DB::Nonce;

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

    my $user = Toks::DB::User->new(email => $params->{email})->load;

    if (!$user) {
        $validator->add_error(email => $self->loc('Unknown credentials'));
        return;
    }

    if (!$user->check_password($params->{password})) {
        $validator->add_error(email => $self->loc('Unknown credentials'));
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

    my $nonce =
      Toks::DB::Nonce->new(user_id => $self->{user}->get_column('id'))->create;

    $self->scope->auth->login($self->env, {id => $nonce->get_column('id')});

    return $self->redirect('index');
}

1;
