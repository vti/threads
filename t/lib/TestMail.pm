package TestMail;

use strict;
use warnings;

use MIME::Base64 ();

sub setup {
    unlink '/tmp/mailer.log';
}

sub get_last_message {
    my $class = shift;

    my $mail =
      do { local $/; open my $fh, '<', '/tmp/mailer.log' or die $!; <$fh> };

    if (my ($headers, $body) = $mail =~ m/^(.*?)\r?\n\r?\n(.*)$/ms) {
        ($body) = MIME::Base64::decode_base64($body);
        return $headers, $body;
    }

    return;
}

1;
