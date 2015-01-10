package Threads::Helper::Truncate;

use strict;
use warnings;

use parent 'Tu::Helper';

use HTML::Truncate;

sub truncate {
    my $self = shift;
    my ($text, $chars) = @_;

    $chars ||= 200;

    my $ht = HTML::Truncate->new(chars => $chars);

    return $ht->truncate($text);
}

1;
