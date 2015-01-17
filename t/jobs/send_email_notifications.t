use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;
use TestLib;
use TestDB;

use Threads::DB::User;
use Threads::Job::SendEmailNotifications;

subtest 'do nothing when no users with email confirmations' => sub {
    TestDB->setup;

    TestDB->create('User', status => 'active');

    my $mailer = _mock_mailer();

    my $job = _build_job(mailer => $mailer);
    $job->run;

    is $mailer->mocked_called('send'), 0;
};

subtest 'do nothing when user has no not sent notifications' => sub {
    TestDB->setup;

    my $user =
      TestDB->create('User', status => 'active', email_confirmations => 1);
    TestDB->create(
        'Notification',
        user_id  => $user->id,
        reply_id => 1,
        is_sent  => 1
    );

    my $mailer = _mock_mailer();

    my $job = _build_job(mailer => $mailer);
    $job->run;

    is $mailer->mocked_called('send'), 0;
};

subtest 'sends not send notifications' => sub {
    TestDB->setup;

    my $user =
      TestDB->create('User', status => 'active', email_confirmations => 1);
    TestDB->create('Notification', user_id => $user->id, reply_id => 1);
    TestDB->create(
        'Notification',
        user_id  => $user->id,
        reply_id => 2,
        is_sent  => 0
    );

    my $mailer = _mock_mailer();

    my $job = _build_job(mailer => $mailer);
    $job->run;

    is $mailer->mocked_called('send'), 1;
    my (%args) = $mailer->mocked_call_args('send');

    is_deeply \%args, {
        'body' => 'rendered',
        'headers' =>
          ['To', 'foo@bar.com', 'Subject', 'Unread notifications: 2']

    };
};

subtest 'updates not sent notifications' => sub {
    TestDB->setup;

    my $user =
      TestDB->create('User', status => 'active', email_confirmations => 1);
    TestDB->create('Notification', user_id => $user->id, reply_id => 1);

    my $mailer = _mock_mailer();

    my $job = _build_job(mailer => $mailer);
    $job->run;

    my $notification = Threads::DB::Notification->find(first => 1);

    is $notification->is_sent, 1;
};

sub _mock_mailer {
    my $mailer = Test::MonkeyMock->new;
    $mailer->mock(send => sub { });

    return $mailer;
}

sub _mock_i18n {
    my $handle = Test::MonkeyMock->new;
    $handle->mock(loc => sub { $_[1] });

    my $i18n = Test::MonkeyMock->new;
    $i18n->mock(handle => sub { $handle });

    return $i18n;
}

sub _mock_routes {
    my $routes = Test::MonkeyMock->new;
    $routes->mock(build_path => sub { 'path' });

    return $routes;
}

sub _mock_displayer {
    my $displayer = Test::MonkeyMock->new;
    $displayer->mock(render => sub { 'rendered' });

    return $displayer;
}

sub _build_job {
    my (%params) = @_;

    my $job = Threads::Job::SendEmailNotifications->new(
        config => {base_url => 'http://example.com'},
        %params
    );
    $job = Test::MonkeyMock->new($job);

    $params{i18n}      ||= _mock_i18n();
    $params{mailer}    ||= _mock_mailer();
    $params{routes}    ||= _mock_routes();
    $params{displayer} ||= _mock_displayer();

    my $app = Test::MonkeyMock->new;
    $app->mock(
        service => sub { $params{i18n} },
        when    => sub { $_[1] eq 'i18n' }
    );
    $app->mock(
        service => sub { $params{mailer} },
        when    => sub { $_[1] eq 'mailer' }
    );
    $app->mock(
        service => sub { $params{routes} },
        when    => sub { $_[1] eq 'routes' }
    );
    $app->mock(
        service => sub { $params{displayer} },
        when    => sub { $_[1] eq 'displayer' }
    );

    $job->mock(_build_app => sub { $app });

    return $job;
}

done_testing;
