package Threads::Action::ViewThread;

use strict;
use warnings;

use parent 'Tu::Action';

use Digest::MD5 ();
use Time::Piece;
use Threads::DB::Thread;
use Threads::DB::View;

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $thread =
      Threads::DB::Thread->new(id => $thread_id)->load(with => 'user');

    my $user = $self->scope->user;

    my $view;

    my $today = gmtime->strftime('%Y-%m-%d');

    if ($user) {
        $view = Threads::DB::View->find(
            first => 1,
            where => [
                thread_id => $thread_id,
                user_id   => $user->id,
                \"strftime('%Y-%m-%d', datetime(created,'unixepoch')) = '$today'"
            ]
        );
    }

    my $hash = Digest::MD5::md5_hex(($self->req->remote_host || '') . ':'
          . ($self->req->header('User-Agent') || ''));

    $view ||= Threads::DB::View->find(
        first => 1,
        where => [
            thread_id => $thread_id,
            hash      => $hash,
            \"strftime('%Y-%m-%d', datetime(created,'unixepoch')) = '$today'"
        ]
    );

    if (!$view) {
        $view = Threads::DB::View->new(
            thread_id => $thread_id,
            $user
            ? (user_id => $user->id)
            : (),
            hash => $hash
        )->create;
    }

    $thread->views_count(
        Threads::DB::View->table->count(where => [thread_id => $thread_id]));
    $thread->update;

    $thread->related('tags');

    $self->set_var(thread => $thread->to_hash);

    return;
}

1;
