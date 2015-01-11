package Threads::Action::CreateReply;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

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

    return {errors => $errors}, type => 'json';
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

    if ($parent && $parent->user_id != $user->id) {
        Threads::DB::Notification->new(
            user_id  => $parent->related('user')->id,
            reply_id => $reply->id
        )->load_or_create;
    }

    my $redirect = $self->url_for(
        'view_thread',
        id   => $thread->id,
        slug => $thread->slug
    );

    return {redirect => $redirect . '?t='
          . time
          . '#reply-'
          . $reply->id
    }, type => 'json';
}

1;
