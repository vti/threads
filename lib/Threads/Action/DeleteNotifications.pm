package Threads::Action::DeleteNotifications;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::DB::Notification;

sub run {
    my $self = shift;

    my $user = $self->scope->user;

    my $id = $self->req->param('id');

    Threads::DB::Notification->table->delete(
        where => [
            user_id => $user->id,
            $id ? (id => $id) : ()
        ]
    );

    my $url = $self->url_for('list_notifications');

    return $self->new_json_response(200, {redirect => "$url"});
}

1;
