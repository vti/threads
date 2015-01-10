use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Confirmation;
use Threads::Action::Deregister;

subtest 'returns nothing on GET' => sub {
    my $action = _build_action();

    ok !defined $action->run;
};

subtest 'create confirmation token with correct params' => sub {
    TestDB->setup;

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;

    my $action = _build_action(req => POST('/' => {}), 'tu.user' => $user);

    $action->run;

    my $confirmation = Threads::DB::Confirmation->find(first => 1);

    ok $confirmation;
    is $confirmation->get_column('user_id'),
      Threads::DB::User->find(first => 1)->get_column('id');
    like $confirmation->get_column('token'), qr/^[a-z0-9]+$/i;
};

subtest 'send email' => sub {
    TestDB->setup;

    my $mailer = _mock_mailer();

    my $user =
      Threads::DB::User->new(email => 'foo@bar.com', password => 'silly')->create;

    my $action = _build_action(
        req       => POST('/' => {}),
        'tu.user' => $user,
        mailer    => $mailer
    );

    $action->run;

    my (%mail) = $mailer->mocked_call_args('send');
    is_deeply \%mail,
      {
        headers =>
          [To => 'foo@bar.com', Subject => 'Deregistration confirmation'],
        body => ''
      };
};

sub _mock_mailer {
    my $mailer = Test::MonkeyMock->new;
    $mailer->mock(send => sub { });

    return $mailer;
}

sub _build_action {
    my (%params) = @_;

    my $env    = $params{env}    || TestRequest->to_env(%params);
    my $mailer = $params{mailer} || _mock_mailer();

    my $action = Threads::Action::Deregister->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });
    $action->mock(mailer => sub { $mailer });

    return $action;
}

done_testing;
