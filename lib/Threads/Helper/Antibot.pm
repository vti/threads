package Threads::Helper::Antibot;

use strict;
use warnings;

use base 'Tu::Helper';

sub fake_field {
    my $self = shift;

    return $self->{env}->{'antibot.fakefield.html'} || '';
}

sub static {
    my $self = shift;

    return $self->{env}->{'antibot.static.html'} || '';
}

sub captcha {
    my $self = shift;

    my $captcha = {
        text       => $self->{env}->{'antibot.textcaptcha.text'}       || '',
        field_name => $self->{env}->{'antibot.textcaptcha.field_name'} || ''
    };

    return unless $captcha->{text} && $captcha->{field_name};

    return $captcha;
}

1;
