package Threads::Action::ToggleSubscription;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::User;
use Threads::DB::Reply;
use Threads::DB::Subscription;
use Threads::Action::TranslateMixin 'loc';

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};
    return $self->throw_not_found
      unless my $thread = Threads::DB::Thread->new(id => $thread_id)->load;

    my $user = $self->scope->user;

    my $subscription = Threads::DB::Subscription->find(
        first => 1,
        where => [
            user_id   => $user->id,
            thread_id => $thread->id
        ]
    );

    if ($subscription) {
        $subscription->delete;

        return {state => 0}, type => 'json';
    }
    else {
        Threads::DB::Subscription->new(
            user_id   => $user->id,
            thread_id => $thread->id
        )->create;

        return {state => 1}, type => 'json';
    }
}

1;
