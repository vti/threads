package Threads::Action::UpdateReply;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

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

    return {errors => $errors}, type => 'json';
}

sub run {
    my $self = shift;

    my $reply_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $reply = Threads::DB::Reply->new(id => $reply_id)->load;

    my $user = $self->scope->user;

    return $self->throw_not_found
      unless $user->get_column('id') == $reply->get_column('user_id');

    return $self->throw_not_found
      if $reply->count_related('ansestors');

    $self->{reply} = $reply;

    $self->set_var(reply => $reply->to_hash);

    return $self->SUPER::run;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $reply = $self->{reply};
    $reply->set_columns(%$params);
    $reply->update;

    my $thread = $reply->related('thread');

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
