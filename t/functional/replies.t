use strict;
use warnings;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestDB;

use Threads;
use Threads::DB::User;

subtest 'shows 404 when unknown thread' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    my $res = $ua->get('/threads/123/reply');

    is $res->code, 404;
};

#subtest 'shows validation errors' => sub {
#    TestDB->setup;
#
#    my $ua = _build_loggedin_ua();
#
#    $ua->follow_link(text_regex => qr/Create thread/);
#    $ua->submit_form(fields => {title => 'foo', content => 'bar'});
#
#    $ua->submit_form(fields => {});
#
#    like $ua->content, qr/Required/;
#};
#
#subtest 'redirects after creation' => sub {
#    TestDB->setup;
#
#    my $ua = _build_loggedin_ua();
#
#    $ua->follow_link(text_regex => qr/Create thread/);
#    $ua->submit_form(fields => {title => 'foo', content => 'bar'});
#
#    $ua->submit_form(fields => {content => 'my reply'}, button => 'reply');
#
#    like $ua->content, qr/my reply/;
#};

sub _build_loggedin_ua {
    Threads::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
        status   => 'active'
    )->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'silly'});

    return $ua;
}

sub _build_ua {
    my $app = Threads->new;
    return Test::WWW::Mechanize::PSGI->new(app => $app->to_app);
}

done_testing;
