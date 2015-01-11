package Threads::Helper::Acl;

use strict;
use warnings;

use parent 'Tu::Helper';

use Threads::DB::Thread;
use Threads::DB::Reply;

sub is_allowed {
    my $self = shift;
    my ($action, $object) = @_;

    my $user = $self->scope->user;
    return 0 unless $user;

    return 0 unless $user->id == $object->{user_id};

    if ($action eq 'update_thread') {
        return 1;
    }
    elsif ($action eq 'delete_thread') {
        return 0
          unless my $thread =
          Threads::DB::Thread->new(id => $object->{id})->load;
        return 1 if $thread->replies_count == 0;
    }
    elsif ($action eq 'update_reply' || $action eq 'delete_reply') {
        return 0
          unless my $reply = Threads::DB::Reply->new(id => $object->{id})->load;
        return 1 if $reply->count_related('ansestors') == 0;
    }

    return 0;
}

1;
