package Threads::Action::AdminToggleBlocked;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::User;

sub run {
    my $self = shift;

    my $user_id = $self->captures->{id};
    return $self->throw_not_found
      unless my $user = Threads::DB::User->new(id => $user_id)->load;

    return $self->throw_not_found if $user->id == $self->scope->user->id;

    return $self->throw_not_found
      unless grep { $user->status eq $_ } qw(active blocked);

    if ($user->status eq 'active') {
        $user->status('blocked');
    }
    else {
        $user->status('active');
    }

    $user->update;

    return $self->redirect('admin_list_users');
}

1;
