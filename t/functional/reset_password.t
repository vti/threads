use strict;
use warnings;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestMail;
use TestDB;

use Toks;

subtest 'show request password reset page' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->content_contains('Reset password');
};

subtest 'show validation errors' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {});
    $ua->content_contains('Required');
};

subtest 'show validation errors when unkown user' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});
    $ua->content_contains('User does not exist');
};

subtest 'show validation errors when not activated user' => sub {
    TestDB->setup;

    Toks::DB::User->new(email => 'foo@bar.com')->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});
    $ua->content_contains('Account not activated');
};

subtest 'show confirmation needed page' => sub {
    TestDB->setup;

    Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});
    $ua->content_contains('check your email');
};

subtest 'send confirmation email' => sub {
    TestDB->setup;
    TestMail->setup;

    Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});

    my ($headers, $message) = TestMail->get_last_message;

    like $headers, qr/To:\s+foo\@bar\.com/;
};

subtest '404 when wrong confirmation token' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _build_ua();

    my $res = $ua->get('/reset-password/123');

    is $res->code, 404;
};

subtest 'show password reset page' => sub {
    TestDB->setup;
    TestMail->setup;

    Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});

    my (undef, $message) = TestMail->get_last_message;

    my ($confirmation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get_ok($confirmation_link);
    $ua->content_contains('Reset password');
};

subtest 'show validation errors' => sub {
    TestDB->setup;
    TestMail->setup;

    Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});

    my (undef, $message) = TestMail->get_last_message;

    my ($confirmation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get_ok($confirmation_link);

    $ua->submit_form(fields => {});
    $ua->content_contains('Required');
};

subtest 'show validation errors when password do not match' => sub {
    TestDB->setup;
    TestMail->setup;

    Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});

    my (undef, $message) = TestMail->get_last_message;

    my ($confirmation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get_ok($confirmation_link);

    $ua->submit_form(
        fields => {new_password => 'foo', new_password_confirmation => 'bar'});
    $ua->content_contains('Password mismatch');
};

subtest 'show success page' => sub {
    TestDB->setup;
    TestMail->setup;

    Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});

    my (undef, $message) = TestMail->get_last_message;

    my ($confirmation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get_ok($confirmation_link);

    $ua->submit_form(
        fields => {new_password => 'foo', new_password_confirmation => 'foo'});
    $ua->content_contains('was successfully reset');
};

subtest 'change user password' => sub {
    TestDB->setup;
    TestMail->setup;

    Toks::DB::User->new(email => 'foo@bar.com', status => 'active')->create;

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->follow_link(text => 'Reset password');

    $ua->submit_form(fields => {email => 'foo@bar.com'});

    my (undef, $message) = TestMail->get_last_message;

    my ($confirmation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get($confirmation_link);

    $ua->submit_form(
        fields => {new_password => 'foo', new_password_confirmation => 'foo'});

    $ua->follow_link(text => 'Login');
    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'foo'});
    $ua->content_contains('Index');
};

sub _build_ua {
    my $app = Toks->new;
    return Test::WWW::Mechanize::PSGI->new(app => $app->to_app);
}

done_testing;
