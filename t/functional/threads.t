use strict;
use warnings;

use Test::More;
use Test::WWW::Mechanize::PSGI;
use TestLib;
use TestMail;
use TestDB;

use Toks;
use Toks::DB::User;

subtest 'shows 403 when not logged in' => sub {
    TestDB->setup;

    my $ua = _build_ua();

    my $res = $ua->get('/create_thread');

    is $res->code, 403;
};

subtest 'shows validation errors' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    $ua->get('/create_thread');
    $ua->submit_form(fields => {});

    like $ua->content, qr/Required/;
};

subtest 'redirects after creation' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    $ua->get('/create_thread');
    $ua->submit_form(fields => {title => 'foo', content => 'bar'});

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

    my $thread = Toks::DB::Thread->new(user_id => 999)->create;

    my $ua = _build_loggedin_ua();

    my $res = $ua->post('/threads/' . $thread->get_column('id') . '/update');

    is $res->code, 404;
};

subtest 'shows validation errors on update' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    my $user = Toks::DB::User->find(first => 1);
    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    $ua->get('/threads/' . $thread->get_column('id') . '/update');
    $ua->submit_form(fields => {});

    like $ua->content, qr/Required/;
};

subtest 'updates thread' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    my $user = Toks::DB::User->find(first => 1);
    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    $ua->get('/threads/' . $thread->get_column('id') . '/update');
    $ua->submit_form(fields => {title => 'bar', content => 'baz'});

    like $ua->content, qr/bar/;
};

subtest 'shows 404 when deleting unknown thread' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();

    my $res = $ua->post('/threads/123/delete');

    is $res->code, 404;
};

subtest 'shows 404 when deleting foreigner thread' => sub {
    TestDB->setup;

    my $thread = Toks::DB::Thread->new(user_id => 999)->create;

    my $ua = _build_loggedin_ua();

    my $res = $ua->post('/threads/' . $thread->get_column('id') . '/delete');

    is $res->code, 404;
};

subtest 'redirects after deletion' => sub {
    TestDB->setup;

    my $ua = _build_loggedin_ua();
    my $user = Toks::DB::User->find(first => 1);

    my $thread =
      Toks::DB::Thread->new(user_id => $user->get_column('id'))->create;

    $ua->post('/threads/' . $thread->get_column('id') . '/delete');

    like $ua->content, qr/Index/;
};

sub _build_loggedin_ua {
    Toks::DB::User->new(
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
