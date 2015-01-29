package TestFunctional;

use strict;
use warnings;

use File::Basename qw(dirname);
use Test::WWW::Mechanize::PSGI;

sub build_ua {
    my $psgi = do {
        local $/;
        open my $fh, '<', dirname(__FILE__) . '/../../app.psgi' or die $!;
        <$fh>;
    };
    my $app = eval $psgi || die $@;
    return Test::WWW::Mechanize::PSGI->new(app => $app);
}

1;
