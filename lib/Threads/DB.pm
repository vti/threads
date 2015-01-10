package Threads::DB;

use strict;
use warnings;

use parent 'ObjectDB';

sub id { shift->get_column('id') }

1;
