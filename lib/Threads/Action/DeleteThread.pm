package Threads::Action::DeleteThread;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Subscription;

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $thread = Threads::DB::Thread->new(id => $thread_id)->load;

    my $user = $self->scope->user;

    return $self->throw_not_found
      unless $user->get_column('id') == $thread->get_column('user_id');

    return $self->throw_not_found
      if $thread->count_related('replies');

    Threads::DB::Subscription->table->delete(
        where => [thread_id => $thread->get_column('id')]);

    $thread->delete;

    return $self->redirect('index');
}

1;
