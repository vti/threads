package Threads::Helper::Date;

use strict;
use warnings;

use parent 'Tu::Helper';

use Time::Moment;

sub format {
    my $self = shift;
    my ($epoch) = @_;

    return Time::Moment->from_epoch($epoch)->strftime('%Y-%m-%d %H:%M');
}

sub format_rss {
    my $self = shift;
    my ($epoch) = @_;

    return Time::Moment->from_epoch($epoch)->strftime('%a, %d %b %Y %T GMT');
}

sub is_distant_update {
    my $self = shift;
    my ($object) = @_;

    my $created = $object->{created};
    my $updated = $object->{updated};

    return 0 unless $updated;

    return $updated - $created > 15 * 60;
}

1;
