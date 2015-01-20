package Threads::Action::Register::Captcha;

use strict;
use warnings;

use parent 'Tu::Observer::Base';

use Plack::Session;

sub _init {
    my $self = shift;

    $self->_register(
        'AFTER:build_validator' => sub {
            my $self = shift;
            my ($validator) = @_;

            if (_has_captcha($self)) {
                $validator->add_field('captcha');

                $validator->add_rule('captcha', 'captcha',
                    $self->env->{'psgix.session'}->{captcha});
            }
        }
    );

    $self->_register(
        'BEFORE:show,BEFORE:show_errors' => sub {
            my $self = shift;

            _generate_captcha($self) if _has_captcha($self);
        }
    );
}

sub _has_captcha { shift->service('config')->{captcha} ? 1 : 0 }

sub _generate_captcha {
    my $self = shift;

    my $captchas = $self->service('config')->{captcha};

    my $captcha = $captchas->[int(rand(@$captchas))];

    my $session = Plack::Session->new($self->env);
    $session->set(captcha => $captcha->{answer});
    $self->set_var(captcha => {text => $captcha->{text}});
}

1;
