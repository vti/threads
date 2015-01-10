package Threads::Validator::NotDisposableEmail;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

use Threads::DB::DisposableEmailBlacklist;

sub is_valid {
    my $self = shift;
    my ($value) = @_;

    my (undef, $domain) = split /\@/, $value;

    return 0
      if Threads::DB::DisposableEmailBlacklist->find(
        first => 1,
        where => [domain => $domain]
      );

    return 1;
}

1;
