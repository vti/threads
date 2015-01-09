package Toks::Action::CreateReply;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::LimitChecker;
use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Reply;
use Toks::DB::Notification;
use Toks::DB::Subscription;

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

    my $limits_reached =
      Toks::LimitChecker->new->check($config->{limits}->{replies},
        Toks::DB::Reply->new);
    if ($limits_reached) {
        $validator->add_error(content => $self->loc('You are too fast'));
        return 0;
    }

    return 1;
}

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};
    return $self->throw_not_found
      unless my $thread = Toks::DB::Thread->new(id => $thread_id)->load;

    if (my $parent_id = $self->req->param('to')) {
        return $self->throw_not_found
          unless my $parent = Toks::DB::Reply->new(id => $parent_id)->load;

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

    my $reply = Toks::DB::Reply->new(
        %$params,
        thread_id => $thread->get_column('id'),
        user_id   => $user->get_column('id'),
        $parent ? (parent_id => $parent->get_column('id')) : ()
    )->create;

    $thread->set_column(replies_count => $thread->count_related('replies'));
    $thread->set_column(last_activity => time);
    $thread->update;

    my @subscriptions = Toks::DB::Subscription->find(
        where => [
            user_id   => {'!=' => $user->get_column('id')},
            thread_id => $thread->get_column('id'),
        ]
    );

    foreach my $subscription (@subscriptions) {
        Toks::DB::Notification->new(
            user_id  => $subscription->get_column('user_id'),
            reply_id => $reply->get_column('id')
        )->create;
    }

    if ($parent && $parent->get_column('user_id') != $user->get_column('id')) {
        Toks::DB::Notification->new(
            user_id  => $parent->related('user')->get_column('id'),
            reply_id => $reply->get_column('id')
        )->load_or_create;
    }

    my $redirect = $self->url_for(
        'view_thread',
        id   => $thread->get_column('id'),
        slug => $thread->get_column('slug')
    );

    return {redirect => $redirect . '?t='
          . time
          . '#reply-'
          . $reply->get_column('id')
    }, type => 'json';
}

1;
