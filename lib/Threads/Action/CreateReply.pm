package Threads::Action::CreateReply;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Threads::Action::JSONMixin 'new_json_response';
use Threads::LimitChecker;
use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Reply;
use Threads::DB::Notification;
use Threads::DB::Subscription;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('content');

    $validator->add_rule('content', 'Readable');
    $validator->add_rule('content', 'MaxLength', 1024);

    return $validator;
}

sub show_errors {
    my $self = shift;

    my $errors = $self->vars->{errors};

    return $self->new_json_response(200, {errors => $errors});
}

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    my $config = $self->service('config');
    my $user   = $self->scope->user;

    my $limits_reached =
      Threads::LimitChecker->new->check($config->{limits}->{replies},
        $user, Threads::DB::Reply->new);
    if ($limits_reached) {
        $validator->add_error(content => $self->loc('Replying too often'));
        return 0;
    }

    return 1;
}

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};
    return $self->throw_not_found
      unless my $thread = Threads::DB::Thread->new(id => $thread_id)->load;

    if (my $parent_id = $self->req->param('to')) {
        return $self->throw_not_found
          unless my $parent = Threads::DB::Reply->new(id => $parent_id)->load;

        $self->{parent} = $parent;
    }

    $self->{thread} = $thread;

    return $self->SUPER::run;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user   = $self->scope->user;
    my $thread = $self->{thread};
    my $parent = $self->{parent};

    my $reply = Threads::DB::Reply->new(
        %$params,
        thread_id => $thread->id,
        user_id   => $user->id,
        $parent ? (parent_id => $parent->id) : ()
    )->create;

    $thread->replies_count($thread->count_related('replies'));
    $thread->last_activity(time);
    $thread->update;

    $self->_notify_thread_subscribers($thread, $reply);

    if ($parent && $parent->user_id != $user->id) {
        $self->_notify_parent_reply_author($parent, $reply);
    }

    $self->_delete_thread_notifications($thread);

    my $url = $self->url_for(
        'view_thread',
        id   => $thread->id,
        slug => $thread->slug
    );
    $url->query_form(t => time);
    $url->fragment('reply-' . $reply->id);

    return $self->new_json_response(200, {redirect => "$url"});
}

sub _notify_thread_subscribers {
    my $self = shift;
    my ($thread, $reply) = @_;

    my $user = $self->scope->user;

    my @subscriptions = Threads::DB::Subscription->find(
        where => [
            user_id   => {'!=' => $user->id},
            thread_id => $thread->id,
        ]
    );

    foreach my $subscription (@subscriptions) {
        Threads::DB::Notification->new(
            user_id  => $subscription->user_id,
            reply_id => $reply->id
        )->create;
    }

}

sub _notify_parent_reply_author {
    my $self = shift;
    my ($parent, $reply) = @_;

    Threads::DB::Notification->new(
        user_id  => $parent->related('user')->id,
        reply_id => $reply->id
    )->load_or_create;
}

sub _delete_thread_notifications {
    my $self = shift;
    my ($thread) = @_;

    my $user = $self->scope->user;

    my @replies_ids = map { $_->id } $thread->find_related('replies');
    Threads::DB::Notification->table->delete(
        where => [user_id => $user->id, reply_id => \@replies_ids]);
}

1;
