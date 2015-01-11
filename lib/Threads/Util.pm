package Threads::Util;

use strict;
use warnings;

use parent 'Exporter';

our @EXPORT_OK = qw(gentoken to_hex from_hex);

use Math::Random::Secure;

sub gentoken {
    my ($len) = @_;

    $len ||= 32;

    return join '',
      map { pack 'C', Math::Random::Secure::irand(256) } 1 .. $len;
}

sub to_hex ($) {
    my ($bytes) = @_;

    return unpack 'H*', $bytes;
}

sub from_hex ($) {
    my ($hex) = @_;

    return pack 'H*', $hex;
}

1;
