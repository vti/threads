use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;
use TestDB;
use TestLib;

use Threads::DB::Thread;

subtest 'creates simple slug' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => 'Foo')->create;

    $thread = $thread->load;

    is $thread->slug, 'foo';
};

subtest 'updates slug' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => 'Foo')->create;

    $thread = $thread->load;
    $thread->title('Bar');
    $thread->update;

    $thread = $thread->load;

    is $thread->slug, 'bar';
};

subtest 'creates slug from unicode' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => 'Привет, это мы!')->create;

    $thread = $thread->load;

    is $thread->slug, 'привет-это-мы';
};

subtest 'removes double dashes' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => 'Привет, -- это # мы!')->create;

    $thread = $thread->load;

    is $thread->slug, 'привет-это-мы';
};

subtest 'removes leading and trailing dashes' => sub {
    TestDB->setup;

    my $thread = _build_thread(title => '--Привет, -- это # мы!--')->create;

    $thread = $thread->load;

    is $thread->slug, 'привет-это-мы';
};

done_testing;

sub _build_thread {
    Threads::DB::Thread->new(user_id => 1, content => 'foo', @_);
}
