package Threads::Action::ToggleReport;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::ObjectACL;
use Threads::DB::User;
use Threads::DB::Reply;
use Threads::DB::Report;

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};
    return $self->throw_not_found
      unless my $reply = Threads::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    return $self->throw_not_found
      if Threads::ObjectACL->new->is_author($user, $reply);

    my $report = Threads::DB::Report->find(
        first => 1,
        where => [
            user_id  => $user->id,
            reply_id => $reply->id
        ]
    );

    my $state;
    if ($report) {
        $report->delete;
        $state = 0;
    }
    else {
        Threads::DB::Report->new(
            user_id  => $user->id,
            reply_id => $reply->id
        )->create;
        $state = 1;
    }

    my $count = Threads::DB::Report->table->count(where => [reply_id => $reply->id]);
    $reply->reports_count($count);
    $reply->update;

    return {count => $count, state => $state}, type => 'json';
}

1;
