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

    my $user      = $self->scope->user;
    my $page      = $self->param('page') || 1;
    my $page_size = $self->param('page_size') || 10;

    my @notifications = Toks::DB::Notification->find(
        where => [
            user_id    => $user->get_column('id'),
            'reply.id' => {'!=' => ''}
        ],
        page      => $page,
        page_size => $page_size,
        order_by  => [id => 'DESC'],
        with      => [qw/reply reply.user reply.parent.user reply.thread/]
    );

    return map { $_->to_hash } @notifications;
}

1;
