#!/usr/bin/env perl

use strict;
use warnings;

use FindBin '$RealBin';

BEGIN {
    unshift @INC, "$RealBin/lib";
    unshift @INC, "$_/lib" for glob "$RealBin/contrib/*";
}

use AnyEvent;
use JSON ();
use Plack::Builder;
use Plack::App::EventSource;
use Threads;
use Threads::UserLoader;
use Threads::DB::Notification;

my $app = Threads->new;

die 'events not configured' unless my $config = $app->service('config')->{events};

my $last_notification =
  Threads::DB::Notification->find(first => 1, order_by => [id => 'DESC']);
my $last_notification_id = $last_notification ? $last_notification->id : 0;
my $t;

my $connections = {};

builder {
    mount '/' => builder {
        enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
        'Plack::Middleware::ReverseProxy';
        enable '+Tu::Middleware::Defaults',        services => $app->services;
        enable '+Tu::Middleware::Session::Cookie', services => $app->services;
        enable '+Tu::Middleware::User',
          services    => $app->services,
          user_loader => Threads::UserLoader->new(finalize => 0);
        enable sub {
            my $app = shift;
            sub {
                my $env = shift;

                return [
                    404, ['Access-Control-Allow-Origin' => '*'],
                    ['Not found']
                  ]
                  unless $env->{'tu.user'};

                return $app->($env);
              }
        };

        Plack::App::EventSource->new(
            headers => $config->{headers},
            handler_cb => sub {
                my ($conn, $env) = @_;

                my $user = $env->{'tu.user'};

                $connections->{"$conn"} = {
                    conn    => $conn,
                    user_id => $user->id
                };

                _install_timer(sub { _poll() });
            }
        );
    };
};

sub _install_timer {
    my ($cb) = @_;

    $t ||= AnyEvent->timer(
        interval => $config->{poll_timeout} || 5,
        cb       => $cb
    );
}

sub _poll {
    my @user_ids = map { $connections->{$_}->{user_id} } keys %$connections;

    my @notifications = Threads::DB::Notification->find(
        '+columns' => [
            {
                -col => \'COUNT(*)',
                -as  => 'count'
            }
        ],
        where => [
            $last_notification_id ? (id => {'>' => $last_notification_id}) : (),
            user_id => \@user_ids
        ],
        group_by => 'user_id',
        with     => [qw/reply.user/]
    );

    if (@notifications) {
        $last_notification_id = $notifications[-1]->id;

        foreach my $notification (@notifications) {
            my (@conn_keys) =
              grep { $connections->{$_}->{user_id} eq $notification->user_id }
              keys %$connections;
            foreach my $conn_key (@conn_keys) {
                my $conn_info = $connections->{$conn_key};
                my $conn      = $conn_info->{conn};

                my $message = _build_message($notification);
                eval {
                    $conn->push($message);
                    1;
                } or do {
                    delete $connections->{$conn_key};
                    $conn->close;
                };
            }
        }
    }
}

sub _build_message {
    my ($notification) = @_;

    my $total = Threads::DB::Notification->table->count(
        where => [
            user_id    => $notification->user_id,
            'reply.id' => {'!=' => ''}
        ]
    );

    my $more =
        $notification->get_column('count') > 1
      ? $notification->get_column('count') - 1
      : 0;

    JSON::encode_json(
        {
            last_notification => $notification->to_hash,
            total             => $total,
            more              => $more
        }
    );
}
