package Threads::Middleware::Origin;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Plack::Session;
use Tu::Scope;

sub call {
    my $self = shift;
    my ($env) = @_;

    my $dispatched_request = Tu::Scope->new($env)->dispatched_request;
    if ($dispatched_request && (my $action = $dispatched_request->action)) {
        my $session = Plack::Session->new($env);
        my $origin  = $session->get('origin');
        $origin ||= [];
        $origin = [$origin] unless ref $origin eq 'ARRAY';

        if (!@$origin || $origin->[0]->{url} ne $env->{REQUEST_URI}) {
            unshift @$origin, {url => $env->{REQUEST_URI}, action => $action};
        }

        pop @$origin while @$origin > 2;

        $session->set(origin => $origin);
    }

    return $self->app->($env);
}

1;
