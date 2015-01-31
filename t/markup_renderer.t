use strict;
use warnings;
use utf8;

use Test::More;
use TestLib;

use Threads::MarkupRenderer;

subtest 'renders empty markdown' => sub {
    my $helper = _build_renderer();

    is $helper->render(''), '<p></p>';
};

subtest 'renders paragraph' => sub {
    my $helper = _build_renderer();

    is $helper->render('foo'), '<p>foo</p>';
};

subtest 'renders unicode' => sub {
    my $helper = _build_renderer();

    is $helper->render('_привет_'), '<p><em>привет</em></p>';
};

subtest 'renders paragraph with single newlines' => sub {
    my $helper = _build_renderer();

    is $helper->render("foo\nbar"), "<p>foo\nbar</p>";
};

subtest 'renders paragraphs' => sub {
    my $helper = _build_renderer();

    is $helper->render("foo\n\nbar"), "<p>foo</p><p>bar</p>";
};

subtest 'renders code' => sub {
    my $helper = _build_renderer();

    is $helper->render(qq{```\nmy \$foo = "bar"\n```}),
qq{<p><pre class="markup perl"><code>my \$foo = &quot;bar&quot;</code></pre></p>};
};

subtest 'renders em' => sub {
    my $helper = _build_renderer();

    is $helper->render('_italic_'), '<p><em>italic</em></p>';
};

subtest 'renders strong' => sub {
    my $helper = _build_renderer();

    is $helper->render('**italic**'), '<p><strong>italic</strong></p>';
};

subtest 'renders link' => sub {
    my $helper = _build_renderer();

    is $helper->render('[title](http://href)'),
      '<p><a href="http://href" rel="nofollow">title</a></p>';
};

subtest 'forbids html' => sub {
    my $helper = _build_renderer();

    is $helper->render('<a>'), '<p>&lt;a&gt;</p>';
};

subtest 'renders mention' => sub {
    my $helper = _build_renderer();

    is $helper->render('Hi, @foo!'), '<p>Hi, <strong>@foo</strong>!</p>';
};

subtest 'perl specific' => sub {
    my $helper = _build_renderer();

    is $helper->render('module:Foo::Bar'),
      '<p><a href="http://metacpan.org/module/Foo::Bar" rel="nofollow">Foo::Bar</a></p>';
    is $helper->render('author:VTI'),
      '<p><a href="http://metacpan.org/author/VTI" rel="nofollow">VTI</a></p>';
    is $helper->render('release:Foo_Baz'),
      '<p><a href="http://metacpan.org/release/Foo_Baz" rel="nofollow">Foo_Baz</a></p>';
};

sub _build_renderer { Threads::MarkupRenderer->new }

done_testing;
