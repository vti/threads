package TestFunctional;

use strict;
use warnings;

use File::Basename qw(dirname);
use Test::WWW::Mechanize::PSGI;

sub build_ua {
    my $app = eval do {
        local $/;
        open my $fh, '<', dirname(__FILE__) . '/../../app.psgi' or die $!;
        <$fh>;
    };
    return Test::WWW::Mechanize::PSGI->new(app => $app);
}

1;
