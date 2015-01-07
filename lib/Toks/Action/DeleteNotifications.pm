package Toks::Action::DeleteNotifications;

use strict;
use warnings;

use parent 'Tu::Action';

use Toks::DB::User;
use Toks::DB::Notification;

sub run {
    my $self = shift;

    my $user = $self->scope->user;

    my $id = $self->req->param('id');

    Toks::DB::Notification->table->delete(
        where => [
            user_id => $user->get_column('id'),
            $id ? (id => $id) : ()
        ]
    );

    return {redirect => $self->url_for('list_notifications') . ''},
      type => 'json';
}

1;
