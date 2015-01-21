package Threads::Helper::Pager;

use strict;
use warnings;

use parent 'Tu::Helper';

use URI::Escape ();

sub build {
    my $self = shift;
    my (%params) = @_;

    my $query_params = $params{query_params};
    my $base_url     = $params{base_url};
    my $total        = $params{total};
    my $page_size    = $self->param('page_size') || 10;
    my $current_page = $self->param('page') || 1;

    return {} if $total <= $page_size;

    my $first_page = $current_page == 1 ? 0 : 1;
    my $prev_page  = $current_page == 1 ? 0 : $current_page - 1;

    my $last_page = $total / $page_size;
    if ($last_page != int($last_page)) {
        $last_page = int($last_page) + 1;
    }
    my $next_page = $current_page + 1;
    $next_page = 0 if $next_page > $last_page;
    $last_page = 0 if $last_page <= $current_page;

    my @query;
    foreach my $query_param (@$query_params) {
        next unless defined $self->param($query_param);

        push @query,
          URI::Escape::uri_escape($query_param) . '='
          . URI::Escape::uri_escape($self->param($query_param));
    }
    my $query = '&' . join('&', @query);

    return {
        first_page => $first_page,
        $base_url
        ? (first_page_url => $self->_build_url($base_url, $first_page, $query))
        : (),
        prev_page => $prev_page,
        $base_url
        ? (prev_page_url => $self->_build_url($base_url, $prev_page, $query))
        : (),
        next_page => $next_page,
        $base_url
        ? (next_page_url => $self->_build_url($base_url, $next_page, $query))
        : (),
        last_page => $last_page,
        $base_url
        ? (last_page_url => $self->_build_url($base_url, $last_page, $query))
        : (),
    };
}

sub _build_url {
    my $self = shift;
    my ($base_url, $page, $query) = @_;

    return '' unless $page;
    return $base_url . '?page=' . $page . $query;
}

1;
