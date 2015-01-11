use strict;
use warnings;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestMail;
use TestDB;

use Threads;

subtest 'show registration page' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Sign up');

    $ua->content_contains('Registration');
};

subtest 'show validation errors' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Sign up');

    $ua->submit_form(fields => {});
    $ua->content_contains('Required');
};

subtest 'show activation needed page' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Sign up');

    $ua->submit_form(
        fields => {email => 'foo@bar.com', password => 'password'});
    $ua->content_contains('check your email');
};

subtest 'registers with unicode password' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Sign up');

    $ua->submit_form(
        fields => {email => 'foo@bar.com', password => 'привет'});

    $ua->content_contains('check your email');
};

subtest 'send activation email' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Sign up');

    $ua->submit_form(
        fields => {email => 'foo@bar.com', password => 'password'});

    my ($headers, $message) = TestMail->get_last_message;

    like $headers, qr/To:\s+foo\@bar\.com/;
};

subtest 'show 404 when wrong confirmation token' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _build_ua();

    my $res = $ua->get('/confirm-registration/123');

    is $res->code, 404;
};

subtest 'show activation success page' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Sign up');

    $ua->submit_form(
        fields => {email => 'foo@bar.com', password => 'password'});

    my (undef, $message) = TestMail->get_last_message;

    my ($activation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get_ok($activation_link);
    $ua->content_contains('activated');
};

subtest 'activate user' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Sign up');

    $ua->submit_form(
        fields => {email => 'foo@bar.com', password => 'password'});

    my (undef, $message) = TestMail->get_last_message;

    my ($activation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get_ok($activation_link);

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(
        fields => {email => 'foo@bar.com', password => 'password'});
    $ua->content_contains('Sort');
};

subtest 'not found when logged in' => sub {
    TestDB->setup;

    Threads::DB::User->new(
        email    => 'foo@bar.com',
        password => 'password',
        status   => 'active'
    )->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(
        fields => {email => 'foo@bar.com', password => 'password'});

    my $res = $ua->get('/register');

    is $res->code, 404;
};

sub _build_ua {
    my $app = Threads->new;
    return Test::WWW::Mechanize::PSGI->new(app => $app->to_app);
}

done_testing;
