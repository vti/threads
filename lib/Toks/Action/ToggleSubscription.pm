package Toks::Action::ToggleSubscription;

use strict;
use warnings;

use parent 'Tu::Action';

use Toks::DB::User;
use Toks::DB::Reply;
use Toks::DB::Subscription;
use Toks::Action::TranslateMixin 'loc';

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};
    return $self->throw_not_found
      unless my $thread = Toks::DB::Thread->new(id => $thread_id)->load;

    my $user = $self->scope->user;

    my $subscription = Toks::DB::Subscription->find(
        first => 1,
        where => [
            user_id   => $user->get_column('id'),
            thread_id => $thread->get_column('id')
        ]
    );

    if ($subscription) {
        $subscription->delete;

        return {state => 0}, type => 'json';
    }
    else {
        Toks::DB::Subscription->new(
            user_id   => $user->get_column('id'),
            thread_id => $thread->get_column('id')
        )->create;

        return {state => 1}, type => 'json';
    }
}

1;
