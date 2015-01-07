package Toks::Helper::Markdown;

use strict;
use warnings;

use parent 'Tu::Helper';

use Text::Markdown;

sub render {
    my $self = shift;
    my ($text) = @_;

    return Text::Markdown->new->markdown($text);
}

1;
