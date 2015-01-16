package Threads::Action::Preview;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::MarkupRenderer;

sub run {
    my $self = shift;

    my $content = $self->req->param('content');

    $content = Threads::MarkupRenderer->new->render($content);

    return $self->new_json_response(200, {content => $content});
}

1;
