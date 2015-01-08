use strict;
use warnings;
use utf8;

use Test::More;
use TestLib;

use Toks::Helper::Markup;

subtest 'renders empty markdown' => sub {
    my $helper = _build_helper();

    is $helper->render(''), '<p></p>';
};

subtest 'renders paragraph' => sub {
    my $helper = _build_helper();

    is $helper->render('foo'), '<p>foo</p>';
};

subtest 'renders unicode' => sub {
    my $helper = _build_helper();

    is $helper->render('_привет_'), '<p><em>привет</em></p>';
};

subtest 'renders paragraph with single newlines' => sub {
    my $helper = _build_helper();

    is $helper->render("foo\nbar"), "<p>foo\nbar</p>";
};

subtest 'renders paragraphs' => sub {
    my $helper = _build_helper();

    is $helper->render("foo\n\nbar"), "<p>foo</p><p>bar</p>";
};

subtest 'renders code' => sub {
    my $helper = _build_helper();

    is $helper->render(qq{```\nmy \$foo = "bar"\n```}), qq{<p><pre class="perl"><code>my \$foo = &quot;bar&quot;
</code></pre></p>};
};

subtest 'renders em' => sub {
    my $helper = _build_helper();

    is $helper->render('_italic_'), '<p><em>italic</em></p>';
};

subtest 'renders strong' => sub {
    my $helper = _build_helper();

    is $helper->render('**italic**'), '<p><strong>italic</strong></p>';
};

subtest 'renders link' => sub {
    my $helper = _build_helper();

    is $helper->render('(title)[http://href]'), '<p><a href="http://href">title</a></p>';
};

subtest 'forbids html' => sub {
    my $helper = _build_helper();

    is $helper->render('<a>'), '<p>&lt;a&gt;</p>';
};

my $env = {};
sub _build_helper {
    Toks::Helper::Markup->new(env => $env);
}

done_testing;
