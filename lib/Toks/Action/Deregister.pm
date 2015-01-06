package Toks::Action::Deregister;

use strict;
use warnings;

use parent 'Tu::Action';

use Toks::DB::User;
use Toks::DB::Confirmation;
use Toks::Action::TranslateMixin 'loc';

sub run {
    my $self = shift;

    return if $self->req->method eq 'GET';

    my $user = $self->env->{'tu.user'};

    my $confirmation =
      Toks::DB::Confirmation->new(user_id => $user->get_column('id'))->create;

    my $email = $self->render(
        'email/deregistration_confirmation_required',
        layout => undef,
        vars   => {
            email => $user->get_column('email'),
            token => $confirmation->get_column('token')
        }
    );

    $self->mailer->send(
        headers => [
            To      => $user->get_column('email'),
            Subject => $self->loc('Deregistration confirmation')
        ],
        body => $email
    );

    return $self->render(
        'deregistration_confirmation_needed',
        vars => {email => $user->get_column('email')}
    );
}

sub mailer {
    my $self = shift;

    return $self->service('mailer');
}

1;
