package Toks::Validator::Email;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

use Email::Valid ();

sub is_valid {
    my $self = shift;
    my ($value) = @_;

    my $ok = Email::Valid->address(
        -address => $value,
        ($ENV{PLACK_ENV} || '') eq 'production'
        ? (-mxcheck => 1, -tldcheck => 1)
        : ()
    );

    return 0 unless $ok;

    return 1;
}

1;
