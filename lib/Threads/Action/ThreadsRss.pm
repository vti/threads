package Threads::Action::ThreadsRss;

use strict;
use warnings;

use parent 'Tu::Action';

use List::Util qw(first);
use Threads::DB::Tag;

sub run {
    my $self = shift;

    my $tag = $self->req->param('tag');
    $self->throw_not_found
      if $tag && !Threads::DB::Tag->new(title => $tag)->load;

    my $params = {
        tag       => $tag,
        page      => 1,
        page_size => 100
    };

    my $rss = $self->render(
        'threads_rss',
        layout => undef,
        vars   => {params => $params}
    );

    my $res = $self->req->new_response(200);
    $res->header('Content-Type' => 'application/rss+xml; charset=utf-8');
    $res->body($rss);

    return $res;
}

1;
