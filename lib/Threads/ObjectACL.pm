package Threads::ObjectACL;

use strict;
use warnings;
use attrs;

use Scalar::Util qw(blessed);
use Threads::DB::Thread;
use Threads::DB::Reply;

sub is_author {
    my $self = shift;
    my ($user, $object) = @_;

    return 0 unless $user;

    $object = $object->to_hash if blessed $object;

    return 0 unless $user->id == $object->{user_id};

    return 1;
}

sub is_allowed {
    my $self = shift;
    my ($user, $object, $action) = @_;

    return 0 unless $user;

    $object = $object->to_hash if blessed $object;

    return 0 unless $user->id == $object->{user_id} || $user->role eq 'admin';

    if ($action eq 'update_thread') {
        return 1;
    }
    elsif ($action eq 'delete_thread') {
        return 0
          unless my $thread =
          Threads::DB::Thread->new(id => $object->{id})->load;
        return 1 if $thread->count_related('replies') == 0;
    }
    elsif ($action eq 'update_reply' || $action eq 'delete_reply') {
        return 0
          unless my $reply = Threads::DB::Reply->new(id => $object->{id})->load;
        return 1 if $reply->count_related('ansestors') == 0;
    }

    return 0;
}

1;
