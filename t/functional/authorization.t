use strict;
use warnings;
use utf8;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestMail;
use TestDB;

use Toks;
use Toks::DB::User;

subtest 'show login page' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->content_contains('Authorization');
};

subtest 'show validation errors' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {});
    $ua->content_contains('Required');
};

subtest 'show validation errors when unknown user' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'silly'});
    $ua->content_contains('Unknown credentials');
};

subtest 'show validation errors when wrong password' => sub {
    TestDB->setup;
    Toks::DB::User->new(
        email    => 'foo@bar.com',
        password => 'another'
    )->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'silly'});
    $ua->content_contains('Unknown credentials');
};

subtest 'show validation errors when wrong unicode password' => sub {
    TestDB->setup;
    Toks::DB::User->new(
        email    => 'foo@bar.com',
        password => 'another'
    )->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'привет'});
    $ua->content_contains('Unknown credentials');
};

subtest 'show validation errors when user not activated' => sub {
    TestDB->setup;
    Toks::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly'
    )->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'silly'});
    $ua->content_contains('Account not activated');
};

subtest 'redirect to root' => sub {
    TestDB->setup;
    Toks::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
        status   => 'active'
    )->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'silly'});
    $ua->content_contains('Sort');
};

subtest 'logout is forbidden when not logged in' => sub {
    my $ua = _build_ua();

    my $res = $ua->post('/logout');
    is $res->code, 403;
};

subtest 'logout' => sub {
    TestDB->setup;
    Toks::DB::User->new(
        email    => 'foo@bar.com',
        password => 'silly',
        status   => 'active'
    )->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'silly'});

    $ua->post('/logout');

    $ua->content_contains('Login');
};

sub _build_ua {
    my $app = Toks->new;
    return Test::WWW::Mechanize::PSGI->new(app => $app->to_app);
}

done_testing;
