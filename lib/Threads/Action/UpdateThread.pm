package Threads::Action::UpdateThread;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Threads::DB::Thread;

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

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $thread = Threads::DB::Thread->new(id => $thread_id)->load;

    my $user = $self->scope->user;

    return $self->throw_not_found
      unless $user->get_column('id') == $thread->get_column('user_id');

    $self->{thread} = $thread;

    $self->set_var(thread => $thread->to_hash);

    return $self->SUPER::run;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $thread = $self->{thread};
    $thread->set_columns(%$params);
    $thread->updated(time);
    $thread->last_activity(time);
    $thread->update;

    return $self->redirect(
        'view_thread',
        id   => $thread->get_column('id'),
        slug => $thread->get_column('slug')
    );
}

1;
