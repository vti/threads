package Threads::Action::DeleteSubscriptions;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::DB::Subscription;

sub run {
    my $self = shift;

    my $user = $self->scope->user;

    Threads::DB::Subscription->table->delete(where => [user_id => $user->id]);

    my $url = $self->url_for('list_subscriptions');

    return $self->new_json_response(200, {redirect => "$url"});
}

1;
