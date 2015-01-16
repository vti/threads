package Threads::Action::ChangePassword;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Carp qw(croak);
use Threads::DB::User;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('old_password');
    $validator->add_field('new_password');
    $validator->add_field('new_password_confirmation');

    $validator->add_group_rule('new_password',
        [qw/new_password new_password_confirmation/], 'compare');

    return $validator;
}

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    my $user = $self->scope->user;

    if (!$user->check_password($params->{old_password})) {
        $validator->add_error(old_password => $self->loc('Invalid password'));
        return 0;
    }

    return 1;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->scope->user;

    $user->update_password($params->{new_password});

    return $self->render('password_changed');
}

1;
