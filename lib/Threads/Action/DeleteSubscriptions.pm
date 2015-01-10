package Threads::Action::DeleteSubscriptions;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::User;
use Threads::DB::Subscription;

sub run {
    my $self = shift;

    my $user = $self->scope->user;

    Threads::DB::Subscription->table->delete(
        where => [
            user_id => $user->get_column('id'),
        ]
    );

    return {redirect => $self->url_for('list_subscriptions') . ''},
      type => 'json';
}

1;
