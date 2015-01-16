use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestRequest;

use JSON qw(decode_json);
use HTTP::Request::Common;
use Threads::Action::Preview;

subtest 'renders content' => sub {
    my $action = _build_action(req => POST('/' => {content => '**bold**'}));

    my $res = $action->run;

    is_deeply decode_json $res->body,
      {content => '<p><strong>bold</strong></p>'};
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::Preview->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
