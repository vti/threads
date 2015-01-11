use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestDB;
use TestLib;

use Threads::DB::Reply;

subtest 'creates top reply' => sub {
    TestDB->setup;

    my $reply = _build_reply()->create;

    $reply = $reply->load;

    is $reply->parent_id, 0;
    is $reply->level,     0;
    is $reply->lft,       2;
    is $reply->rgt,       3;
};

subtest 'creates second top reply' => sub {
    TestDB->setup;

    _build_reply()->create;

    my $reply = _build_reply(content => 2)->create;
    $reply = $reply->load;

    is $reply->parent_id, 0;
    is $reply->level,     0;
    is $reply->lft,       4;
    is $reply->rgt,       5;
};

subtest 'creates subreplies' => sub {
    TestDB->setup;

    my $reply = _build_reply()->create;

    my @children = $reply->create_related('ansestors', user_id => 1, content => 'child');

    is $children[0]->parent_id, $reply->id;
    is $children[0]->level,     1;
    is $children[0]->lft,       3;
    is $children[0]->rgt,       4;
};

subtest 'deletes subreplies' => sub {
    TestDB->setup;

    my $reply = _build_reply()->create;

    my @children = $reply->create_related('ansestors', user_id => 1, content => 'child');
    $_->delete for @children;

    $reply->load;

    is $reply->parent_id, 0;
    is $reply->level,     0;
    is $reply->lft,       2;
    is $reply->rgt,       3;
};

subtest 'creates deeper subreplies' => sub {
    TestDB->setup;

    my $reply = _build_reply()->create;

    my @children = $reply->create_related('ansestors', user_id => 1, content => 'child');
    my @grandchildren =
      $children[0]->create_related('ansestors', user_id => 1, content => 'child of child');

    is $grandchildren[0]->parent_id,
      $children[0]->id;
    is $grandchildren[0]->level, 2;
    is $grandchildren[0]->lft,   4;
    is $grandchildren[0]->rgt,   5;
};

subtest 'selects in right order' => sub {
    TestDB->setup;

    my $top_reply = _build_reply(content => 'top')->create;
    $top_reply->create_related('ansestors', user_id => 1, content => 'child');

    my $top_reply2 = _build_reply(content => 'top2')->create;

    my @replies = _build_reply()->find(order_by => [lft => 'ASC']);

    is $replies[0]->content, 'top';
    is $replies[1]->content, 'child';
    is $replies[2]->content, 'top2';
};

done_testing;

sub _build_reply {
    Threads::DB::Reply->new(thread_id => 1, user_id => 1, content => 'foo', @_);
}
