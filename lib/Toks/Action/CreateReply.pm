package Toks::Action::CreateReply;

use strict;
use warnings;

use parent 'Toks::Action::FormBase';

use Toks::DB::User;
use Toks::DB::Thread;
use Toks::DB::Reply;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('content');

    return $validator;
}

sub show_errors { shift->throw_error('Invalid request', 400) }

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

    my $user = $self->scope->user;
    my $thread = $self->{thread};
    my $parent = $self->{parent};

    my $reply = Toks::DB::Reply->new(
        %$params,
        thread_id => $thread->get_column('id'),
        user_id   => $user->get_column('id'),
        $parent ? (parent_id => $parent->get_column('id')) : ()
    )->create;

    $thread->set_column(
        replies_count => $thread->count_related('replies'));
    $thread->update;

    return $self->redirect(
        'view_thread',
        id   => $thread->get_column('id'),
        slug => $thread->get_column('slug')
    );
}

1;
