package Threads::Notificator;

use strict;
use warnings;

use List::MoreUtils qw(uniq);
use Threads::DB::Notification;
use Threads::DB::User;
use Threads::MarkupRenderer;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub notify_mentioned_users {
    my $self = shift;
    my ($user, $reply) = @_;

    my $content = $reply->content;

    my $markup = Threads::MarkupRenderer->new;
    my $translated = $markup->translate($content);

    my @mentions = uniq $translated->{text} =~ m/\@([a-z0-9_-]{1,32})/ims;

    foreach my $mention (@mentions) {
        my $mentioned_user = Threads::DB::User->new(name => $mention)->load;
        next unless $mentioned_user;

        next if $mentioned_user->id == $user->id;

        Threads::DB::Notification->new(
            user_id  => $mentioned_user->id,
            reply_id => $reply->id
        )->load_or_create;
    }
}


1;
