package Threads::Helper::Subscription;

use strict;
use warnings;

use parent 'Tu::Helper';

use Threads::DB::Subscription;

sub is_subscribed {
    my $self = shift;
    my ($thread) = @_;

    my $user = $self->scope->user;
    return 0 unless $user;

    return 1
      if Threads::DB::Subscription->find(
        first => 1,
        where =>
          [thread_id => $thread->{id}, user_id => $user->get_column('id')]
      );

    return 0;
}

sub find {
    my $self = shift;

    my $user = $self->scope->user;

    my @subscriptions = Threads::DB::Subscription->find(
        where => [
            user_id     => $user->get_column('id'),
            'thread.id' => {'!=' => ''}
        ],
        with => ['thread', 'thread.user']
    );

    return map { $_->to_hash } @subscriptions;
}

sub count {
    my $self = shift;

    my $user = $self->scope->user;

    return Threads::DB::Subscription->table->count(
        where => [
            user_id     => $user->get_column('id'),
            'thread.id' => {'!=' => ''}
        ]
    );
}

1;
