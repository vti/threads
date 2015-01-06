use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Toks::DB::Thread;
use Toks::Action::ViewThread;

subtest 'throws 404 when no thread' => sub {
    TestDB->setup;

    my $action = _build_action(captures => {});

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'returns nothing on success' => sub {
    TestDB->setup;

    my $thread = Toks::DB::Thread->new(user_id => 1)->create;

    my $action = _build_action(captures => {id => $thread->get_column('id')});

    $action->run;

    ok $action->scope->displayer->vars->{thread};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Toks::Action::ViewThread->new(env => $env);

    return $action;
}

done_testing;
