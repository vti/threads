package Threads::Helper::Antibot;

use strict;
use warnings;

use base 'Tu::Helper';

sub fake_field {
    my $self = shift;

    return $self->{env}->{'plack.antibot.fakefield.html'} || '';
}

sub static {
    my $self = shift;

    return $self->{env}->{'plack.antibot.static.html'} || '';
}

sub captcha {
    my $self = shift;

    my $env     = $self->{env};
    my $captcha = {
        text       => $env->{'plack.antibot.textcaptcha.text'}       || '',
        field_name => $env->{'plack.antibot.textcaptcha.field_name'} || ''
    };

    return unless $captcha->{text} && $captcha->{field_name};

    return $captcha;
}

1;
