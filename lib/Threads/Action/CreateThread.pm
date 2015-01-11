package Threads::Action::CreateThread;

use strict;
use warnings;

use parent 'Threads::Action::FormBase';

use Threads::LimitChecker;
use Threads::DB::User;
use Threads::DB::Thread;
use Threads::DB::Subscription;

sub build_validator {
    my $self = shift;

    my $validator = $self->SUPER::build_validator;

    $validator->add_field('title');
    $validator->add_field('content');
    $validator->add_optional_field('tags');

    $validator->add_rule('title',   'Readable');
    $validator->add_rule('title',   'MaxLength', 255);
    $validator->add_rule('content', 'MaxLength', 5 * 1024);
    $validator->add_rule('tags',    'Tags');

    return $validator;
}

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    my $config = $self->service('config');
    my $user   = $self->scope->user;

    my $limits_reached =
      Threads::LimitChecker->new->check($config->{limits}->{threads},
        $user, Threads::DB::Thread->new);
    if ($limits_reached) {
        $validator->add_error(
            title => $self->loc('Creating threads too often'));
        return 0;
    }

    return 1;
}

sub submit {
    my $self = shift;
    my ($params) = @_;

    my $user = $self->scope->user;

    my $thread =
      Threads::DB::Thread->new(%$params, user_id => $user->id)
      ->create;

    Threads::DB::Subscription->new(
        user_id   => $user->id,
        thread_id => $thread->id
    )->create;

    if ($params->{tags}) {
        my @tags = grep { $_ ne '' && /\w/ } split /\s*,\s*/, $params->{tags};

        $thread->create_related('tags', title => $_) for @tags;
    }

    return $self->redirect(
        'view_thread',
        id   => $thread->id,
        slug => $thread->slug
    );
}

1;
