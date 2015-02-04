package Threads::Helper::Url;

use strict;
use warnings;

use parent 'Tu::Helper';

use URI::Escape qw(uri_escape_utf8);

sub DESTROY { }

our $AUTOLOAD;

sub AUTOLOAD {
    my $self = shift;

    my $method = $AUTOLOAD;

    return if $method =~ /^[A-Z]+?$/;
    return if $method =~ /^_/;

    $method = (split /::/ => $method)[-1];

    my $language = $self->{env}->{'plack.i18n.language'};
    my $i18n     = $self->{services}->service('i18n');

    my $url = join '/', map { uri_escape_utf8($_) } split '/',
      $self->service('routes')->build_path($method, @_);
    $url = '/' if $url eq '';

    if ($language && $language ne $i18n->default_language) {
        $url = '/' . $language . $url;
    }

    return $url;
}

1;
