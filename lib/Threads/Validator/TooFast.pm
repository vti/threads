package Threads::Validator::TooFast;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

use Plack::Session;

sub is_valid {
    my $self = shift;
    my ($value) = @_;

    my $env = $self->{args}->[0] || {};

    my $session = Plack::Session->new($env);

    return 0 unless my $too_fast = $session->get('too_fast');

    return 0 unless time - $too_fast > 1;

    return 1;
}

1;
