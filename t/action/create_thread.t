use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Tag;
use Threads::DB::Subscription;
use Threads::Action::CreateThread;

subtest 'returns nothing on GET' => sub {
    my $action = _build_action();

    ok !defined $action->run;
};

subtest 'set template var errors' => sub {
    my $action = _build_action(req => POST('/' => {}));

    $action->run;

    $action->env;

    ok $action->scope->displayer->vars->{errors};
};

subtest 'shows error when limits' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;

    my $services = _mock_services(config => {limits => {threads => {60 => 5}}});

    my $action = _build_action(
        req => POST(
            '/' =>
              {title => 'This is a title, with ?# symbols', content => 'bar'}
        ),
        'tu.user' => $user,
        services  => $services
    );

    $action->run for 1 .. 10;

    is(Threads::DB::Thread->table->count, 5);
    is $action->vars->{errors}->{title}, 'Creating threads too often';
};

subtest 'creates thread with correct params' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req => POST(
            '/' =>
              {title => 'This is a title, with ?# symbols', content => 'bar'}
        ),
        'tu.user' => $user
    );

    $action->run;

    my $thread = Threads::DB::Thread->find(first => 1);

    ok $thread;
    is $thread->user_id, $user->id;
    is $thread->slug,    'this-is-a-title-with-symbols';
    is $thread->title,   'This is a title, with ?# symbols';
    is $thread->content, 'bar';
    isnt $thread->last_activity, 0;
    like $thread->last_activity, qr/^\d+$/;
};

subtest 'creates thread with tags' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req => POST(
            '/' =>
              {title => 'Title', content => 'bar', tags => 'foo,bar,baz'}
        ),
        'tu.user' => $user
    );

    $action->run;

    my @tags = Threads::DB::Tag->find(order_by => ['title' => 'ASC']);

    is @tags, 3;
    is $tags[0]->title, 'bar';
    is $tags[1]->title, 'baz';
    is $tags[2]->title, 'foo';
};

subtest 'redirects to thread view' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req       => POST('/' => {title => 'foo', content => 'bar'}),
        'tu.user' => $user
    );

    $action->mock('redirect');

    $action->run;

    my ($name) = $action->mocked_call_args('redirect');

    is $name, 'view_thread';
};

subtest 'creates subscription' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'bar')->create;

    my $action = _build_action(
        req       => POST('/' => {title => 'foo', content => 'bar'}),
        'tu.user' => $user
    );

    $action->mock('redirect');

    $action->run;

    my $thread = Threads::DB::Thread->find(first => 1);
    my $subscription = Threads::DB::Subscription->find(first => 1);

    ok $subscription;
    is $subscription->user_id,   $user->id;
    is $subscription->thread_id, $thread->id;
};

sub _mock_services {
    my (%params) = @_;

    my $services = Test::MonkeyMock->new;
    $services->mock(
        service => sub { $params{config} || {} },
        when => sub { $_[1] eq 'config' }
    );
    return $services;
}

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::CreateThread->new(
        env      => $env,
        services => $params{services} || _mock_services()
    );
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
