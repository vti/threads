package Toks::Job::CleanupThreadViews;

use strict;
use warnings;

use parent 'Toks::Job::Base';

use Toks::DB::View;

sub run {
    my $self = shift;

    my $week_ago = time - 7 * 24 * 3600;

    my $views_to_remove =
      Toks::DB::View->table->count(where => [created => {'<=' => $week_ago}]);

    if ($views_to_remove) {
        print 'Deleting ' . $views_to_remove . ' view(s)' . "\n";

        Toks::DB::View->table->delete(where => [created => {'<=' => $week_ago}])
          unless $self->{dry_run};
    }
    else {
        print "Nothing to remove\n" if $self->_is_verbose;
    }

    return $self;
}

1;
