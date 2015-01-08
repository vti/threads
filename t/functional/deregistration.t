use strict;
use warnings;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestMail;
use TestDB;

use Toks;
use Toks::DB::User;

subtest 'forbidden when not logged in' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    my $res = $ua->get('/deregister');

    is $res->code, 403;
};

subtest 'show deregistration page' => sub {
    TestDB->setup;

    my $ua = _login();

    $ua->follow_link(text => 'Settings');
    $ua->follow_link(text => 'Remove account');

    $ua->content_contains('Deregistration');
};

subtest 'show deregistration confirmation needed page' => sub {
    TestDB->setup;

    my $ua = _login();

    $ua->follow_link(text => 'Settings');
    $ua->follow_link(text => 'Remove account');

    $ua->submit_form(fields => {}, form_id => 'deregister');
    $ua->content_contains('check your email');
};

subtest 'send activation email' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _login();

    $ua->follow_link(text => 'Settings');
    $ua->follow_link(text => 'Remove account');

    $ua->submit_form(fields => {}, form_id => 'deregister');

    my ($headers, $message) = TestMail->get_last_message;

    like $headers, qr/To:\s+foo\@bar\.com/;
};

subtest '404 when wrong activation token' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _login();

    my $res = $ua->get('/confirm_deregistration/123');

    is $res->code, 404;
};

subtest 'show confirmation success page' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _login();

    $ua->follow_link(text => 'Settings');
    $ua->follow_link(text => 'Remove account');

    $ua->submit_form(fields => {}, form_id => 'deregister');

    my (undef, $message) = TestMail->get_last_message;

    my ($confirmation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get_ok($confirmation_link);
    $ua->content_contains('account was successfully removed');
};

subtest 'remove account' => sub {
    TestDB->setup;
    TestMail->setup;

    my $ua = _login();

    $ua->follow_link(text => 'Settings');
    $ua->follow_link(text => 'Remove account');

    $ua->submit_form(fields => {}, form_id => 'deregister');

    my (undef, $message) = TestMail->get_last_message;

    my ($confirmation_link) = $message =~ m/(http:.*?)\n/ms;

    $ua->get_ok($confirmation_link);

    $ua->get('/');
    $ua->follow_link(text => 'Login');
    $ua->submit_form(
        fields  => {email => 'foo@bar.com', password => 'silly'},
        form_id => 'login'
    );
    $ua->content_contains('Unknown credentials');
};

sub _login {
    my $user = Toks::DB::User->new(
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
    my $app = Toks->new;
    return Test::WWW::Mechanize::PSGI->new(app => $app->to_app);
}

done_testing;
