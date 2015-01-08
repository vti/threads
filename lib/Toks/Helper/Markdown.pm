package Toks::Helper::Markdown;

use strict;
use warnings;

use parent 'Tu::Helper';

use Text::Markdown;

sub render {
    my $self = shift;
    my ($text) = @_;

    $text =~ s{&}{&amp;}g;
    $text =~ s{>}{&gt;}g;
    $text =~ s{<}{&lt;}g;
    $text =~ s{"}{&quot;}g;

    $text =~ s{^&gt; }{> }mg;

    return Text::Markdown->new->markdown($text);
}

1;
