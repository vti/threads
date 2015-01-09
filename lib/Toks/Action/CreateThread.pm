package Toks::Action::CreateThread;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Subscription;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('title');
    $validator->add_field('content');

    $validator->add_rule('title', 'Readable');
    $validator->add_rule('title', 'MaxLength', 255);
    $validator->add_rule('content', 'MaxLength', 5 * 1024);

    return $validator;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->scope->user;

    my $thread =
      Toks::DB::Thread->new(%$params, user_id => $user->get_column('id'))
      ->create;

    Toks::DB::Subscription->new(
        user_id   => $user->get_column('id'),
        thread_id => $thread->get_column('id')
    )->create;

    return $self->redirect(
        'view_thread',
        id   => $thread->get_column('id'),
        slug => $thread->get_column('slug')
    );
}

1;
