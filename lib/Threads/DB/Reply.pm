package Threads::DB::Reply;

use strict;
use warnings;

use base 'Threads::DB';

__PACKAGE__->meta(
    table   => 'replies',
    columns => [
        qw/
          id
          created
          user_id
          thread_id
          parent_id
          level
          rgt
          lft
          content
          thanks_count
          reports_count
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    relationships  => {
        thread => {
            type  => 'many to one',
            class => 'Threads::DB::Thread',
            map   => {thread_id => 'id'}
        },
        parent => {
            type  => 'many to one',
            class => 'Threads::DB::Reply',
            map   => {parent_id => 'id'}
        },
        ansestors => {
            type  => 'one to many',
            class => 'Threads::DB::Reply',
            map   => {id => 'parent_id'}
        },
        user => {
            type  => 'many to one',
            class => 'Threads::DB::User',
            map   => {user_id => 'id'}
        }
    }
);

sub create {
    my $self = shift;

    my $rgt         = 1;
    my $level       = 0;
    my $reply_count = 0;

    if ($self->column('parent_id')) {
        my $parent = $self->find_related('parent');

        if ($parent) {
            $level = $parent->column('level') + 1;

            $rgt = $parent->column('lft');

            $self->set_column(thread_id => $parent->get_column('thread_id'));
        }
    }

    $reply_count = $self->table->count;

    if ($reply_count) {
        my $left = $self->find(
            first => 1,
            where => [
                parent_id => ($self->column('parent_id') || 0)
            ],
            order_by => [created => 'DESC', id => 'DESC']
        );

        $rgt = $left->column('rgt') if $left;

        $self->table->update(
            set   => {'rgt' => \'rgt + 2'},
            where => [rgt   => {'>' => $rgt}]
        );

        $self->table->update(
            set   => {'lft' => \'lft + 2'},
            where => [lft   => {'>' => $rgt}]
        );
    }

    $self->column(lft   => $rgt + 1);
    $self->column(rgt   => $rgt + 2);
    $self->column(level => $level);

    return $self->SUPER::create;
}

sub delete {
    my $self = shift;

    my $lft   = $self->get_column('lft');
    my $rgt   = $self->get_column('rgt');
    my $width = $rgt - $lft + 1;

    $self->table->delete(
        where => [
            lft => {'>' => $lft},
            lft => {'<' => $rgt}
        ]
    );

    $self->table->update(
        set   => {rgt => \"rgt - $width"},
        where => [rgt => {'>' => $rgt}]
    );
    $self->table->update(
        set   => {lft => \"lft - $width"},
        where => [lft => {'>' => $rgt}]
    );

    return $self->SUPER::delete;
}

1;
