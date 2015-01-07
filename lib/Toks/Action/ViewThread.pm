package Toks::Action::ViewThread;

use strict;
use warnings;

use parent 'Tu::Action';

use Toks::DB::Thread;

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $thread =
      Toks::DB::Thread->new(id => $thread_id)->load(with => 'user');

    $self->set_var(thread => $thread->to_hash);

    return;
}

1;
