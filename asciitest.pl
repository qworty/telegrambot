#!/usr/bin/perl -w

use strict;

my $String="This is Ascii";

$String=~s/(.)/ord($1)/eg;

print "Ascii: $String\n";
