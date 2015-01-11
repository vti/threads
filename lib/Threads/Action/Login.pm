package Threads::Action::Login;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Threads::DB::User;
use Threads::DB::Nonce;
use Threads::DB::Confirmation;

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

    if ($user->status eq 'new') {
        $validator->add_error(email => $self->loc('Account not activated'));
        return;
    }

    if ($user->status eq 'blocked') {
        $validator->add_error(email => $self->loc('Account blocked'));
        return;
    }

    if ($user->status ne 'active') {
        $validator->add_error(email => $self->loc('Account not active'));
        return;
    }

    $self->{user} = $user;

    return 1;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->{user};

    my $nonce =
      Threads::DB::Nonce->new(user_id => $user->id)->create;

    $self->scope->auth->login($self->env, {id => $nonce->id});

    Threads::DB::Confirmation->table->delete(
        where => [user_id => $user->id, type => 'reset_password']);

    return $self->redirect('index');
}

1;
