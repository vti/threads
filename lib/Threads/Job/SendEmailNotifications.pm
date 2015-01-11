package Threads::Job::SendEmailNotifications;

use strict;
use warnings;

use parent 'Threads::Job::Base';

use Threads;
use Threads::DB::User;
use Threads::DB::Notification;

sub run {
    my $self = shift;

    my $app = Threads->new;

    my @users =
      Threads::DB::User->find(
        where => [status => 'active', email_notifications => 1]);

    my $i18n = $app->service('i18n');
    my $i18n_handle =
      $i18n->handle($self->_config->{i18n}->{default_language});
    my $mailer    = $app->service('mailer');
    my $displayer = $app->service('displayer');

    foreach my $user (@users) {
        my @not_sent_notifications =
          Threads::DB::Notification->find(
            where => [user_id => $user->id, is_sent => 0]);

        if (@not_sent_notifications) {
            my $email = $displayer->render(
                'email/notifications_digest',
                layout => undef,
                vars   => {
                    notifications => \@not_sent_notifications,
                    loc           => sub { $i18n_handle->loc(@_) },
                    url           => $self->_config->{base_url}
                      . $app->service('routes')
                      ->build_path('list_notifications')
                }
            );

            $mailer->send(
                headers => [
                    To      => $user->email,
                    Subject => $i18n_handle->loc('Unread notifications: ')
                      . scalar(@not_sent_notifications)
                ],
                body => $email
            );

            Threads::DB::Notification->table->update(
                where => [user_id => $user->id, is_sent => 0],
                set   => [is_sent => 1]
            );
        }
    }

    return $self;
}

1;
