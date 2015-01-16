package Threads::Action::ToggleReport;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::ObjectACL;
use Threads::DB::User;
use Threads::DB::Reply;
use Threads::DB::Report;

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};
    return $self->new_json_response(404)
      unless my $reply = Threads::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    return $self->new_json_response(404)
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

    my $count =
      Threads::DB::Report->table->count(where => [reply_id => $reply->id]);
    $reply->reports_count($count);
    $reply->update;

    return $self->new_json_response(200, {count => $count, state => $state});
}

1;
