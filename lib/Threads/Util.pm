package Threads::Util;

use strict;
use warnings;

use parent 'Exporter';

our @EXPORT_OK = qw(gentoken to_hex from_hex);

use Time::HiRes qw(gettimeofday);
use Math::Random::ISAAC;

sub gentoken {
    my ($len) = @_;

    $len ||= 32;

    my $seed;

    if (-e '/dev/urandom') {
        if (open my $fh, '<', '/dev/urandom') {
            read $fh, $seed, 4;
            close $fh;

            $seed = unpack 'L', $seed;
        }
    }

    if (!defined $seed) {
        my ($seconds, $microseconds) = gettimeofday();

        $microseconds .= '0' while length $microseconds < 6;

        $seed = $seconds . $microseconds;
    }

    my $rng = Math::Random::ISAAC->new($seed);

    return join '', map { pack 'L', $rng->irand } 1 .. $len / 4;
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
