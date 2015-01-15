package Threads::Helper::AdminUser;

use strict;
use warnings;

use parent 'Tu::Helper';

use Threads::DB::User;

sub find {
    my $self = shift;
    my (%params) = @_;

    my $page      = $self->param('page')      || 1;
    my $page_size = $self->param('page_size') || 10;

    return map { $_->to_hash } Threads::DB::User->find(
        page      => $page,
        page_size => $page_size,
        order_by  => [id => 'DESC']
    );
}

sub count {
    my $self = shift;
    my (%params) = @_;

    return Threads::DB::User->table->count;
}

1;
