package Threads::Helper::Reply;

use strict;
use warnings;

use parent 'Tu::Helper';

use Threads::DB::Reply;
use Threads::DB::Thank;

sub find_by_thread {
    my $self = shift;
    my ($thread) = @_;

    my @replies = Threads::DB::Reply->find(
        where    => [thread_id => $thread->{id}],
        order_by => [lft       => 'ASC'],
        with     => [qw/user parent.user/]
    );

    return map { $_->to_hash } @replies;
}

sub is_thanked {
    my $self = shift;
    my ($reply) = @_;

    my $user = $self->scope->user;

    return
         $reply->{thanks_count} > 0
      && $user
      && Threads::DB::Thank->find(
        first => 1,
        where => [
            reply_id => $reply->{id},
            user_id  => $user->id,
        ]
      ) ? 1 : 0;
}

sub is_flagged {
    my $self = shift;
    my ($reply) = @_;

    my $user = $self->scope->user;

    return
         $reply->{reports_count} > 0
      && $user
      && Threads::DB::Report->find(
        first => 1,
        where => [
            reply_id => $reply->{id},
            user_id  => $user->id,
        ]
      );
}

sub count {
    my $self = shift;
    my ($thread) = @_;

    return Threads::DB::Reply->table->count;
}

1;
