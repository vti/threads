package Threads::Action::Register::TooFast;

use strict;
use warnings;

use parent 'Tu::Observer::Base';

use Plack::Session;

sub _init {
    my $self = shift;

    return unless $ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'production';

    $self->_register(
        'AFTER:build_validator' => sub {
            my $self = shift;
            my ($validator) = @_;

            $validator->add_rule('email', 'TooFast', $self->env);
        }
    );

    $self->_register(
        'BEFORE:show,BEFORE:show_errors' => sub {
            my $self = shift;

            my $session = Plack::Session->new($self->env);
            $session->set(too_fast => time);
        }
    );
}

1;
