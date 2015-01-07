package Toks::Helper::Acl;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::Thread;

sub is_allowed {
    my $self = shift;
    my ($action, $object) = @_;

    my $user = $self->scope->user;
    return 0 unless $user;

    return 0 unless $user->get_column('id') == $object->{user_id};

    if ($action =~ m/^update_/) {
        return 1;
    }
    elsif ($action eq 'delete_thread') {
        return 0 unless my $thread = Toks::DB::Thread->new(id => $object->{id})->load;
        return 1 if $thread->get_column('replies_count') == 0;
    }

    return 0;
}

1;
