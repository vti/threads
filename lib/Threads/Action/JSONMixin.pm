package Threads::Action::JSONMixin;

use strict;
use warnings;

use parent 'Exporter';

our @EXPORT_OK = qw(new_json_response);

use JSON ();

sub new_json_response {
    my $self = shift;
    my ($status, $perl) = @_;

    my $json = JSON::encode_json($perl || {});

    return $self->new_response(
        $status,
        [
            'Content-Type'   => 'application/json',
            'Content-Length' => length($json)
        ],
        $json
    );
}

1;
