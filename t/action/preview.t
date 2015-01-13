use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestLib;
use TestRequest;

use HTTP::Request::Common;
use Threads::Action::Preview;

subtest 'not found when not POST' => sub {
    my $action = _build_action(req => GET('/'));

    my $e = exception { $action->run };

    is $e->code, 404;
};

subtest 'renders content' => sub {
    my $action = _build_action(req => POST('/' => {content => '**bold**'}));

    my ($json) = $action->run;

    is $json->{content}, '<p><strong>bold</strong></p>';
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || TestRequest->to_env(%params);

    my $action = Threads::Action::Preview->new(env => $env);
    $action = Test::MonkeyMock->new($action);

    return $action;
}

done_testing;
