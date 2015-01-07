use strict;
use warnings;

use Test::More;
use Test::Fatal;
use TestDB;
use TestLib;

use Toks::DB::Reply;

subtest 'creates top reply' => sub {
    TestDB->setup;

    my $reply = _build_reply()->create;

    $reply = $reply->load;

    is $reply->get_column('parent_id'), 0;
    is $reply->get_column('level'),     0;
    is $reply->get_column('lft'),       2;
    is $reply->get_column('rgt'),       3;
};

subtest 'creates second top reply' => sub {
    TestDB->setup;

    _build_reply()->create;

    my $reply = _build_reply(content => 2)->create;
    $reply = $reply->load;

    is $reply->get_column('parent_id'), 0;
    is $reply->get_column('level'),     0;
    is $reply->get_column('lft'),       4;
    is $reply->get_column('rgt'),       5;
};

subtest 'creates subreplies' => sub {
    TestDB->setup;

    my $reply = _build_reply()->create;

    my @children = $reply->create_related('ansestors', user_id => 1, content => 'child');

    is $children[0]->get_column('parent_id'), $reply->get_column('id');
    is $children[0]->get_column('level'),     1;
    is $children[0]->get_column('lft'),       3;
    is $children[0]->get_column('rgt'),       4;
};

subtest 'deletes subreplies' => sub {
    TestDB->setup;

    my $reply = _build_reply()->create;

    my @children = $reply->create_related('ansestors', user_id => 1, content => 'child');
    $_->delete for @children;

    $reply->load;

    is $reply->get_column('parent_id'), 0;
    is $reply->get_column('level'),     0;
    is $reply->get_column('lft'),       2;
    is $reply->get_column('rgt'),       3;
};

subtest 'creates deeper subreplies' => sub {
    TestDB->setup;

    my $reply = _build_reply()->create;

    my @children = $reply->create_related('ansestors', user_id => 1, content => 'child');
    my @grandchildren =
      $children[0]->create_related('ansestors', user_id => 1, content => 'child of child');

    is $grandchildren[0]->get_column('parent_id'),
      $children[0]->get_column('id');
    is $grandchildren[0]->get_column('level'), 2;
    is $grandchildren[0]->get_column('lft'),   4;
    is $grandchildren[0]->get_column('rgt'),   5;
};

subtest 'selects in right order' => sub {
    TestDB->setup;

    my $top_reply = _build_reply(content => 'top')->create;
    $top_reply->create_related('ansestors', user_id => 1, content => 'child');

    my $top_reply2 = _build_reply(content => 'top2')->create;

    my @replies = _build_reply()->find(order_by => [lft => 'ASC']);

    is $replies[0]->get_column('content'), 'top';
    is $replies[1]->get_column('content'), 'child';
    is $replies[2]->get_column('content'), 'top2';
};

done_testing;

sub _build_reply {
    Toks::DB::Reply->new(thread_id => 1, user_id => 1, content => 'foo', @_);
}
