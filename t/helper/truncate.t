use strict;
use warnings;
use utf8;

use Test::More;
use TestLib;

use Threads::Helper::Truncate;

subtest 'truncates less than' => sub {
    my $helper = _build_helper();

    is $helper->truncate('123'), '123';
};

subtest 'truncates more than' => sub {
    my $helper = _build_helper();

    is $helper->truncate('12345678901', 10), '1234567890&#8230;';
};

subtest 'truncates correctly html code' => sub {
    my $helper = _build_helper();

    is $helper->truncate('<p>very very very very long</p>', 10),
      '<p>very very&#8230;</p>';
};

subtest 'truncates correctly unicode' => sub {
    my $helper = _build_helper();

    is $helper->truncate(
        '<p>очень очень очень длинная строка</p>',
        10),
      '<p>очень очен&#8230;</p>';
};

my $env = {};

sub _build_helper {
    Threads::Helper::Truncate->new(env => $env);
}

done_testing;
