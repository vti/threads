package Toks::Action::CreateThread;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::DB::User;
use Toks::DB::Thread;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('title');
    $validator->add_field('content');

    return $validator;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->scope->user;

    my $thread =
      Toks::DB::Thread->new(%$params, user_id => $user->get_column('id'))
      ->create;

    return $self->redirect('view_thread', id => $thread->get_column('id'));
}

1;
