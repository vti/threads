package Toks::Helper::Subscription;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::Subscription;

sub is_subscribed {
    my $self = shift;
    my ($thread) = @_;

    my $user = $self->scope->user;
    return 0 unless $user->role eq 'user';

    return 1
      if Toks::DB::Subscription->find(
        first => 1,
        where =>
          [thread_id => $thread->{id}, user_id => $user->get_column('id')]
      );

    return 0;
}

sub find {
    my $self = shift;

    my $user = $self->scope->user;

    my @subscriptions = Toks::DB::Subscription->find(
        where => [
            user_id     => $user->get_column('id'),
            'thread.id' => {'!=' => ''}
        ],
        with => 'thread'
    );

    return map { $_->to_hash } @subscriptions;
}

1;
