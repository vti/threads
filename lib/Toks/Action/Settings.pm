package Toks::Action::Settings;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_optional_field('name');
    $validator->add_optional_field('email_notifications');

    return $validator;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->env->{'tu.user'};

    $user->set_columns(%$params);
    $user->update;

    return $self->redirect('index');
}

1;
