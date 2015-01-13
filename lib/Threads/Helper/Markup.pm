package Threads::Helper::Markup;

use strict;
use warnings;

use parent 'Tu::Helper';

use Threads::MarkupRenderer;

sub render {
    my $self = shift;
    my ($text) = @_;

    return Threads::MarkupRenderer->new->render($text);
}

1;
