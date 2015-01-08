package Toks::Helper::Notification;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::Notification;

sub count {
    my $self = shift;

    my $user = $self->scope->user;

    return Toks::DB::Notification->table->count(
        where => [
            user_id    => $user->get_column('id'),
            'reply.id' => {'!=' => ''}
        ]
    );
}

sub find {
    my $self = shift;

    my $user = $self->scope->user;

    my @notifications = Toks::DB::Notification->find(
        where => [
            user_id    => $user->get_column('id'),
            'reply.id' => {'!=' => ''}
        ],
        order_by => [id => 'DESC'],
        with     => [qw/reply reply.thread.user reply.user2/]
    );

    return map { $_->to_hash } @notifications;
}

1;
