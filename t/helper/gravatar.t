use strict;
use warnings;

use Test::More;
use TestLib;

use Toks::Helper::Gravatar;

subtest 'returns gravatar when in production' => sub {
    my $helper = _build_helper();

    local $ENV{PLACK_ENV} = 'production';
    is $helper->img({email => 'foo@bar.com', status => 'active'}),
'<img src="http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8.jpg?s=40" />';
};

subtest 'returns default gravatar when in development' => sub {
    my $helper = _build_helper();

    is $helper->img({email => 'foo@bar.com', status => 'active'}),
      '<img src="/images/gravatar-40.jpg" />';
};

subtest 'accepts size in development' => sub {
    my $helper = _build_helper();

    is $helper->img({email => 'foo@bar.com', status => 'active'}, 20),
      '<img src="/images/gravatar-20.jpg" />';
};

subtest 'accepts size in production' => sub {
    my $helper = _build_helper();

    local $ENV{PLACK_ENV} = 'production';
    is $helper->img({email => 'foo@bar.com', status => 'active'}, 20),
      '<img src="http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8.jpg?s=20" />';
};

subtest 'returns default gravatar when user deleted' => sub {
    my $helper = _build_helper();

    local $ENV{PLACK_ENV} = 'production';
    is $helper->img({email => 'foo@bar.com', status => 'deleted'}),
      '<img src="/images/gravatar-40.jpg" />';
};

my $env = {};

sub _build_helper {
    Toks::Helper::Gravatar->new(env => $env);
}

done_testing;
