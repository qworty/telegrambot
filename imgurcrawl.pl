#!/usr/bin/perl
use strict;
use warnings FATAL=>'all';

use LWP::Simple;

my $crawlterm = shift(@ARGV);
die "No crawlterm given" unless($crawlterm);

my $imgurlink = "http://imgur.com/r/$crawlterm";

my $page = `curl $imgurlink`;
my $piclist = {};
my $count = 0;
my @pictures;
`mkdir -p crawl/$crawlterm`;
if($page){
  print $page;
  while($page =~ /div.*?class="post"(.*?)\/div/gs){
    $count++;
    my $picdiv = $1;
    #print $picdiv;
    if($picdiv =~ /\<img.*?src="(.*?)".*?\>/is){
      my $piclink = $1;
      $piclink =~ /(.*)\/(.*)\.(.*)$/;
      my $pic = $1;
      my $picname = $2;
      my $ext = $3;
      $picname =~ s/b$//;
      print $piclink." => $pic/$picname.$ext\n";
      my $picurl = "http:$pic/$picname.$ext";
      `wget $picurl -O crawl/$crawlterm/$picname.$ext`;
    }
  }
}else{
  print "Oops.. boo boo happened\n";
}

print $count."\n";

