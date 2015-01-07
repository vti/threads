package Toks::Helper::Gravatar;

use strict;
use warnings;

use parent 'Tu::Helper';

use Digest::MD5 qw(md5_hex);

sub img {
    my $self = shift;
    my ($email) = @_;

    my $hash = md5_hex lc $email;

    if ($ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'production') {
        return qq{<img src="http://www.gravatar.com/avatar/$hash.jpg?s=40" />};
    }
    else {
        return '<img src="/images/gravatar.jpg" />';
    }
}

1;
