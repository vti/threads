use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;
use TestDB;
use TestLib;

use Toks::DB::Thread;

subtest 'creates simple slug' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => 'Foo')->create;

    $thread = $thread->load;

    is $thread->get_column('slug'), 'foo';
};

subtest 'updates slug' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => 'Foo')->create;

    $thread = $thread->load;
    $thread->set_column(title => 'Bar');
    $thread->update;

    $thread = $thread->load;

    is $thread->get_column('slug'), 'bar';
};

subtest 'creates slug from unicode' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => 'Привет, это мы!')->create;

    $thread = $thread->load;

    is $thread->get_column('slug'), 'привет-это-мы';
};

subtest 'removes double dashes' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => 'Привет, -- это # мы!')->create;

    $thread = $thread->load;

    is $thread->get_column('slug'), 'привет-это-мы';
};

subtest 'removes leading and trailing dashes' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => '--Привет, -- это # мы!--')->create;

    $thread = $thread->load;

    is $thread->get_column('slug'), 'привет-это-мы';
};

done_testing;

sub _build_thread {
    Toks::DB::Thread->new(user_id => 1, content => 'foo', @_);
}
