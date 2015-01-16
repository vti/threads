package Threads::Action::UpdateReply;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Threads::ObjectACL;
use Threads::DB::Reply;

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

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};

    return $self->new_json_response(404)
      unless my $reply = Threads::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    return $self->new_json_response(404)
      unless Threads::ObjectACL->new->is_allowed($user, $reply, 'update_reply');

    $self->{reply} = $reply;

    $self->set_var(reply => $reply->to_hash);

    return $self->SUPER::run;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $reply = $self->{reply};
    $reply->set_columns(%$params, updated => time);
    $reply->update;

    my $thread = $reply->related('thread');

    my $url = $self->url_for(
        'view_thread',
        id   => $thread->id,
        slug => $thread->slug
    );
    $url->query_form(t => time);
    $url->fragment('reply-' . $reply->id);

    return $self->new_json_response(200, {redirect => "$url"});
}

1;
