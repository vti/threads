package Toks::Helper::Truncate;

use strict;
use warnings;

use parent 'Tu::Helper';

use HTML::Truncate;

sub truncate {
    my $self = shift;
    my ($text, $chars) = @_;

    $chars ||= 200;

    my $ht = HTML::Truncate->new(chars => $chars);

    my $truncated = $ht->truncate(Encode::encode('UTF-8', $text));

    return Encode::decode('UTF-8', $truncated);
}

1;
