use strict;
use warnings;

use Test::More;
use TestLib;

use Toks::Helper::Markdown;

subtest 'renders empty markdown' => sub {
    my $helper = _build_helper();

    is $helper->render(''), "\n";
};

subtest 'renders markdown' => sub {
    my $helper = _build_helper();

    is $helper->render("# hi there\n*and here*"), "<h1>hi there</h1>

<p><em>and here</em></p>\n";
};

subtest 'forbids html' => sub {
    my $helper = _build_helper();

    is $helper->render('<a>'), "<p>&lt;a&gt;</p>\n";
};

my $env = {};
sub _build_helper {
    Toks::Helper::Markdown->new(env => $env);
}

done_testing;
