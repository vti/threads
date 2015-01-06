#!/usr/bin/env perl

use strict;
use warnings;

use File::Copy ();
use Locale::Maketext::Extract::Run 'xgettext';

my ($dir) = @ARGV;
die 'Usage: <locale_dir>' unless $dir && -d $dir;

xgettext('-D', 'lib', '-D', 'templates');

my $messages =
  do { local $/; open my $fh, '<', 'messages.po' or die $!; <$fh> };
$messages =~ s{^.*?\n\n}{}ms;
open my $fh, '>', 'messages.po' or die $!;
print $fh $messages;
close $fh;

my @files = glob "$dir/*.po";
for my $file (@files) {
    File::Copy::move($file, "$file.bak");
    system("msgmerge $file.bak messages.po | msguniq > $file");
    unlink "$file.bak";
}

unlink 'messages.po';
