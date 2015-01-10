package Threads::Job::CleanupInactiveRegistrations;

use strict;
use warnings;

use parent 'Threads::Job::Base';

use Threads::DB::User;

sub run {
    my $self = shift;

    my $week_ago = time - 7 * 24 * 3600;

    my @inactive_users =
      Threads::DB::User->find(
        where => [status => 'new', created => {'<=' => $week_ago}]);
    print "Nothing to remove\n" if $self->_is_verbose && !@inactive_users;

    foreach my $user (@inactive_users) {
        if ($self->_is_verbose) {
            print 'Deleting ' . $user->get_column('id'), "\n";
        }

        $user->delete unless $self->{dry_run};
    }

    return $self;
}

1;
