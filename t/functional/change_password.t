use strict;
use warnings;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestDB;
use TestFunctional;

use Threads;

subtest 'show not found when not logged in' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    my $res = $ua->get('/change-password');

    is $res->code, 404;
};

subtest 'show change password page' => sub {
    TestDB->setup;

    my $ua = _login();

    $ua->get('/profile');
    $ua->follow_link(text => 'Change password');

    $ua->content_contains('Change password');
};

subtest 'show validation errors' => sub {
    TestDB->setup;

    my $ua = _login();

    $ua->get('/profile');
    $ua->follow_link(text => 'Change password');

    $ua->submit_form(fields => {}, form_id => 'change-password');
    $ua->content_contains('Required');
};

subtest 'show error when wrong password' => sub {
    TestDB->setup;

    my $ua = _login();

    $ua->get('/profile');
    $ua->follow_link(text => 'Change password');

    $ua->submit_form(
        fields => {
            email                     => 'foo@bar.com',
            old_password              => 'wrong',
            new_password              => 'foo',
            new_password_confirmation => 'foo'
        },
        form_id => 'change-password'
    );
    $ua->content_contains('Invalid');
};

subtest 'show error when new passwords do not match' => sub {
    TestDB->setup;

    my $ua = _login();

    $ua->get('/profile');
    $ua->follow_link(text => 'Change password');

    $ua->submit_form(
        fields => {
            email                     => 'foo@bar.com',
            old_password              => 'silly',
            new_password              => 'foo',
            new_password_confirmation => 'bar'
        },
        form_id => 'change-password'
    );
    $ua->content_contains('Password mismatch');
};

subtest 'show password changed page' => sub {
    TestDB->setup;

    my $ua = _login();

    $ua->get('/profile');
    $ua->follow_link(text => 'Change password');

    $ua->submit_form(
        fields => {
            email                     => 'foo@bar.com',
            old_password              => 'silly',
            new_password              => 'foo',
            new_password_confirmation => 'foo'
        },
        form_id => 'change-password'
    );
    $ua->content_contains('Password changed');
};

subtest 'login with new password' => sub {
    TestDB->setup;

    my $ua = _login();

    $ua->get('/profile');
    $ua->follow_link(text => 'Change password');

    $ua->submit_form(
        fields => {
            email                     => 'foo@bar.com',
            old_password              => 'silly',
            new_password              => 'foo',
            new_password_confirmation => 'foo'
        },
        form_id => 'change-password'
    );

    $ua->follow_link(text => 'Logout');

    $ua->follow_link(text => 'Login');
    $ua->submit_form(fields => {email => 'foo@bar.com', password => 'foo'});

    $ua->content_contains('Sort');
};

sub _login {
    my $user = Threads::DB::User->new(
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

sub _build_ua { TestFunctional->build_ua }

done_testing;
