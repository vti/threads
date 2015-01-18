package TestLib;

use strict;
use warnings;

use File::Spec;
use File::Basename qw(dirname);

BEGIN {
    unshift @INC, "$_/lib"
      for glob File::Spec->catfile(dirname(__FILE__), '../../contrib/*');

    $ENV{PLACK_ENV} = 'test';
}

1;
