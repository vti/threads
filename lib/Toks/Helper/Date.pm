package Toks::Helper::Date;

use strict;
use warnings;

use parent 'Tu::Helper';

use Time::Piece;

sub format {
    my $self = shift;
    my ($epoch) = @_;

    return Time::Piece->new($epoch)->strftime('%Y-%m-%d %T');
}

1;
