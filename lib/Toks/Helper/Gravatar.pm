package Toks::Helper::Gravatar;

use strict;
use warnings;

use parent 'Tu::Helper';

use Digest::MD5 qw(md5_hex);

sub img {
    my $self = shift;
    my ($user, $size) = @_;

    $size ||= 40;

    if (   $user->{status} ne 'deleted'
        && $ENV{PLACK_ENV}
        && $ENV{PLACK_ENV} eq 'production')
    {
        my $email = $user->{email};

        my $hash = md5_hex lc $email;

        return
          qq{<img src="http://www.gravatar.com/avatar/$hash.jpg?s=$size" />};
    }
    else {
        return qq{<img src="/images/gravatar-$size.jpg" />};
    }
}

1;
