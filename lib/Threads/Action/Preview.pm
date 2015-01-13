package Threads::Action::Preview;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::MarkupRenderer;

sub run {
    my $self = shift;

    return $self->throw_not_found unless $self->req->method eq 'POST';

    my $content = $self->req->param('content');

    $content = Threads::MarkupRenderer->new->render($content);

    return {content => $content}, type => 'json';
}

1;
