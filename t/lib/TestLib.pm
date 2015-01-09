package TestLib;

use strict;
use warnings;

use base 'Exporter';

BEGIN {
    use FindBin '$RealBin';
    unshift @INC, "$_/lib" for glob "$RealBin/../../contrib/*";
}

sub import {
    $ENV{PLACK_ENV} = 'test';

    __PACKAGE__->export_to_level(1, @_);
}

1;
