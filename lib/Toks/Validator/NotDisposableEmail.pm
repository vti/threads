package Toks::Validator::NotDisposableEmail;

use strict;
use warnings;

use parent 'Tu::Validator::Base';

use Toks::DB::DisposableEmailBlacklist;

sub is_valid {
    my $self = shift;
    my ($value) = @_;

    my (undef, $domain) = split /\@/, $value;

    return 0
      if Toks::DB::DisposableEmailBlacklist->find(
        first => 1,
        where => [domain => $domain]
      );

    return 1;
}

1;
