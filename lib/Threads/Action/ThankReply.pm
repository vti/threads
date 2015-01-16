package Threads::Action::ThankReply;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::ObjectACL;
use Threads::DB::User;
use Threads::DB::Reply;
use Threads::DB::Thank;

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};
    return $self->new_json_response(404)
      unless my $reply = Threads::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    my $count =
      Threads::DB::Thank->table->count(where => [reply_id => $reply->id]);

    return $self->new_json_response(404)
      if Threads::ObjectACL->new->is_author($user, $reply);

    my $thank = Threads::DB::Thank->find(
        first => 1,
        where => [
            user_id  => $user->id,
            reply_id => $reply->id
        ]
    );

    my $state;
    if ($thank) {
        $thank->delete;

        $state = 0;

        $count--;
    }
    else {
        Threads::DB::Thank->new(
            user_id  => $user->id,
            reply_id => $reply->id
        )->create;

        $count++;

        $state = 1;
    }

    $reply->thanks_count($count);
    $reply->update;

    return $self->new_json_response(200,
        {count => $count == 0 ? '' : $count, state => $state});
}

1;
