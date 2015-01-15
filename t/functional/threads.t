use strict;
use warnings;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestMail;
use TestDB;

use Threads;
use Threads::DB::User;

subtest 'not found when not logged in' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    my $res = $ua->get('/create-thread');

    is $res->code, 404;
};

subtest 'shows validation errors' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    $ua->get('/create-thread');
    $ua->submit_form(fields => {}, form_id => 'create-thread');

    like $ua->content, qr/Required/;
};

subtest 'redirects after creation' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    $ua->get('/create-thread');
    $ua->submit_form(
        fields  => {title => 'foo', content => 'bar'},
        form_id => 'create-thread'
    );

    like $ua->content, qr/foo/;
};

subtest 'shows 404 when updating unknown thread' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    my $res = $ua->post('/threads/123/update');

    is $res->code, 404;
};

subtest 'shows 404 when updating foreigner thread' => sub {
    TestDB->setup;

    my $thread = Threads::DB::Thread->new(user_id => 999)->create;

    my $ua = _build_loggedin_ua();

    my $res = $ua->post('/threads/' . $thread->id . '/update');

    is $res->code, 404;
};

subtest 'shows validation errors on update' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    my $user = Threads::DB::User->find(first => 1);
    my $thread =
      Threads::DB::Thread->new(user_id => $user->id)->create;

    $ua->get('/threads/' . $thread->id . '/update');
    $ua->submit_form(fields => {}, form_id => 'update-thread');

    like $ua->content, qr/Required/;
};

#subtest 'updates thread' => sub {
#    TestDB->setup;
#
#    my $ua = _build_loggedin_ua();
#
#    my $user = Threads::DB::User->find(first => 1);
#    my $thread =
#      Threads::DB::Thread->new(user_id => $user->id)->create;
#
#    $ua->get('/threads/' . $thread->id . '/update');
#    $ua->submit_form(fields => {title => 'bar', content => 'baz'});
#
#    like $ua->content, qr/bar/;
#};

subtest 'shows 404 when deleting unknown thread' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    my $res = $ua->post('/threads/123/delete');

    is $res->code, 404;
};

subtest 'shows 404 when deleting foreigner thread' => sub {
    TestDB->setup;

    my $thread = Threads::DB::Thread->new(user_id => 999)->create;

    my $ua = _build_loggedin_ua();

    my $res = $ua->post('/threads/' . $thread->id . '/delete');

    is $res->code, 404;
};

subtest 'redirects after deletion' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();
    my $user = Threads::DB::User->find(first => 1);

    my $thread =
      Threads::DB::Thread->new(user_id => $user->id)->create;

    $ua->post('/threads/' . $thread->id . '/delete');

    like $ua->content, qr/Sort/;
};

sub _build_loggedin_ua {
    TestDB->create('User', status => 'active');

    my $ua = _build_ua();

    $ua->get('/');
    $ua->follow_link(text => 'Login');

    $ua->submit_form(
        fields  => {email => 'foo@bar.com', password => 'silly'},
        form_id => 'login'
    );

    return $ua;
}

sub _build_ua {
    my $app = Threads->new;
    return Test::WWW::Mechanize::PSGI->new(app => $app->to_app);
}

done_testing;
