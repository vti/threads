package Toks::Action::Register;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::DB::User;
use Toks::DB::Confirmation;

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

    if (Toks::DB::User->new(email => $params->{email})->load) {
        $validator->add_error(email => $self->loc('User exists'));
        return;
    }

    return 1;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my ($name) = split /\@/, $params->{email};

    if (Toks::DB::User->find(first => 1, where => [name => $name])) {
        $name = '';
    }

    my $user = Toks::DB::User->new(%$params, name => $name)->create;

    my $confirmation =
      Toks::DB::Confirmation->new(user_id => $user->get_column('id'))->create;

    my $email = $self->render(
        'email/confirmation_required',
        layout => undef,
        vars   => {
            email => $params->{email},
            token => $confirmation->get_column('token')
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
