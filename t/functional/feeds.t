use strict;
use warnings;
use utf8;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestDB;
use TestFunctional;

use Threads;
use Threads::DB::User;

subtest 'renders empty feed' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/threads.rss');

    $ua->content_contains('xml');
};

subtest 'renders feed with threads' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/create-thread');
    $ua->submit_form(
        fields => {
            title   => 'Foo',
            tags    => 'foo, bar',
            content => 'This is a new thread'
        },
        form_id => 'create-thread'
    );

    $ua->get('/threads.rss');

    $ua->content_contains('Foo');
};

sub _build_ua {
    Threads::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
        status   => 'active'
    )->create;

    my $ua = TestFunctional->build_ua;

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'silly'});

    return $ua;
}

done_testing;
