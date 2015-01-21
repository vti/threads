use strict;
use warnings;

use Test::More;
use TestLib;
use TestRequest;

use Threads::Helper::Pager;

subtest 'builds pager when zeros' => sub {
    my $helper = _build_helper(params => {page_size => 10, page => 1});

    is_deeply $helper->build(total => 0), {};
};

subtest 'builds pager when less than page_size' => sub {
    my $helper = _build_helper(params => {page_size => 10, page => 1});

    is_deeply $helper->build(total => 5),
      {};
};

subtest 'builds pager when first page' => sub {
    my $helper = _build_helper(params => {page_size => 10, page => 1});

    is_deeply $helper->build(total => 11), {
        first_page => 0,
        prev_page  => 0,
        next_page  => 2,
        last_page  => 2

    };
};

subtest 'builds pager when last page' => sub {
    my $helper = _build_helper(params => {page_size => 3, page => 3});

    is_deeply $helper->build(total => 8), {
        first_page => 1,
        prev_page  => 2,
        next_page  => 0,
        last_page  => 0
    };
};

subtest 'builds pager when last page exactly' => sub {
    my $helper = _build_helper(params => {page_size => 10, page => 2});

    is_deeply $helper->build(total => 20), {
        first_page => 1,
        prev_page  => 1,
        next_page  => 0,
        last_page  => 0

    };
};

subtest 'builds pager when over last page' => sub {
    my $helper = _build_helper(params => {page_size => 10, page => 10});

    is_deeply $helper->build(total => 11), {
        first_page => 1,
        prev_page  => 9,
        next_page  => 0,
        last_page  => 0
    };
};

subtest 'builds pager when urls' => sub {
    my $helper = _build_helper(params => {page_size => 10, page => 1, foo => 'bar'});

    my $pager = $helper->build(total => 11, base_url => '/foo', query_params => ['foo']);

    is $pager->{next_page_url}, '/foo?page=2&foo=bar';
};

my $env;

sub _build_helper {
    my (%params) = @_;

    $env = $params{env} || TestRequest->to_env(%params);
    $env->{'tu.displayer.vars'} = {params => $params{params} || {}};

    Threads::Helper::Pager->new(env => $env);
}

done_testing;
