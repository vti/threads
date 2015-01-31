package Threads::Action::Settings;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Threads::DB::User;
use Threads::Action::TranslateMixin 'loc';

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_optional_field('email_notifications');

    return $validator;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->env->{'tu.user'};

    $params->{email_notifications} = 1 if $params->{email_notifications};

    $user->set_columns(%$params);
    $user->update;

    return $self->redirect('index');
}

1;
