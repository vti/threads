package Toks::Helper::User;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::User;

sub count {
    my $self = shift;
    my (%params) = @_;

    return Toks::DB::User->table->count(where => [status => 'active']);
}

1;
