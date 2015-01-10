package Threads::Action::DeleteNotifications;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::User;
use Threads::DB::Notification;

sub run {
    my $self = shift;

    my $user = $self->scope->user;

    my $id = $self->req->param('id');

    Threads::DB::Notification->table->delete(
        where => [
            user_id => $user->get_column('id'),
            $id ? (id => $id) : ()
        ]
    );

    return {redirect => $self->url_for('list_notifications') . ''},
      type => 'json';
}

1;
