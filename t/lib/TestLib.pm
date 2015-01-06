package TestLib;

use strict;
use warnings;

use base 'Exporter';

sub import {
    $ENV{PLACK_ENV} = 'test';

    __PACKAGE__->export_to_level(1, @_);
}

1;
