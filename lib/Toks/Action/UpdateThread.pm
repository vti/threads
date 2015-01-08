package Toks::Action::UpdateThread;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::DB::Thread;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('title');
    $validator->add_field('content');

    return $validator;
}

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $thread = Toks::DB::Thread->new(id => $thread_id)->load;

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
    $thread->set_column(updated       => time);
    $thread->set_column(last_activity => time);
    $thread->update;

    return $self->redirect(
        'view_thread',
        id   => $thread->get_column('id'),
        slug => $thread->get_column('slug')
    );
}

1;
