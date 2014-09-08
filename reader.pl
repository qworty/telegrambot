#!/usr/bin/perl
#use strict;
#use warnings FATAL=>"all";
use IPC::Open2;
use IO::Handle;
use LWP::Simple;
use Data::Dumper;
$|++;
my $version = "v0.01";
my $tgpath = "telegram";
my $startuptime = localtime(time());
`touch running.bot`;
my ($rh, $wh);
my $pid = open2 ($rh, $wh, $tgpath) or die "can't $tgpath $!";
my $started = 0;
my $running = 1;
my $COLOR_RED="\033[0;31m";
my $COLOR_REDB="\033[1;31m";
my $COLOR_NORMAL="\033[0m";
my $COLOR_GREEN="\033[32;1m";
my $COLOR_GREY="\033[37;1m";
my $COLOR_YELLOW="\033[33;1m";
my $COLOR_BLUE="\033[34;1m";
my $COLOR_MAGENTA="\033[35;1m";
my $COLOR_CYAN="\033[36;1m";
my $COLOR_LCYAN="\033[0;36m";
my $COLOR_INVERSE="\033[7m";
my $colors = {"red"=>"\033[0;31m",
          "redb"=>"\033[1;31m",
          "normal"=>"\033[0m",
          "green"=>"\033[32;1m",
          "grey"=>"\033[37;1m",
          "yellow"=>"\033[33;1m",
          "blue"=>"\033[34;1m",
          "magenta"=>"\033[35;1m",
          "cyan"=>"\033[36;1m",
          "lcyan"=>"\033[0;36m",
          "inverse"=>"\033[7m"};
my $userlist= {"groups"=>[],
            "users"=>[]};
my $busy = 0;
my $msgcount = {};

my $nerdlist = {};

$nerdlist->{nightowl}->{tobias} = 100;
$nerdlist->{nightowl}->{leo} = 80;
$nerdlist->{nightowl}->{anton} = -20;
$nerdlist->{nightowl}->{luigi} = 20;

$nerdlist->{nerdcred}->{tobias} = 100;
$nerdlist->{nerdcred}->{leo} = 102;
$nerdlist->{nerdcred}->{anton} = 50;
$nerdlist->{nerdcred}->{luigi} = 20;

$nerdlist->{awesomeness}->{tobias} = 100;
$nerdlist->{awesomeness}->{leo} = 100;
$nerdlist->{awesomeness}->{anton} = 100;
$nerdlist->{awesomeness}->{luigi} = 100;
          
READ: while(my $data = <$rh>){
  $data = parse_msg($data);
  print $data;
  if($started && $data !~ /BOT/){
    my $msg = disect_msg($data);
    print $msg->{receiver};
    print Dumper $msg;
    if($data =~ /vomitchan/i && !$busy && $data !~ /send_photo/){
      $busy = 1;
      print "vomitchan detected, printing pic\n";
      $wh->say("send_photo $msg->{receiver} /home/tobias/apps/telegrambot.ontw/vomitchan2.jpg") or die $!;
      $busy = 0;
    }
    if($data =~ /FF+?UU+?/ && $data !~ /send_photo/){
      print "rage detected, printing pic";
      $wh->say("send_photo $msg->{receiver} /home/tobias/apps/telegrambot.ontw/rage.jpg") or die $!;
    }
    my $picturestars = {
      "anna"=>{"path"=>"/data/3tb/pictures/annakendrick/","terms"=>["anna","kendrick","qt3.14"]},
      "emma"=>{"path"=>"/data/3tb/pictures/emmastone/","terms"=>["emma"]},
      "zooey"=>{"path"=>"/data/3tb/pictures/zooey/","terms"=>["zooey"]},
      "sarah"=>{"path"=>"/data/3tb/pictures/sarahhyland/","terms"=>["sarah"]},
      "clara"=>{"path"=>"/data/3tb/pictures/claraoswald/","terms"=>["clara"]},
      "nathalie"=>{"path"=>"/data/3tb/pictures/natalieportman/","terms"=>["natalie","jew"]},
      "olivia"=>{"path"=>"/data/3tb/pictures/oliviawilde/","terms"=>["olivia"]},
      "alison"=>{"path"=>"/data/3tb/pictures/alisonbrie/","terms"=>["alison"]},
      "jane"=>{"path"=>"/data/3tb/pictures/janelevy/","terms"=>["jane"]},
      "yvonne"=>{"path"=>"/data/3tb/pictures/uitchuck/","terms"=>["yvonne"]},
      "karengillian"=>{"path"=>"/data/3tb/pictures/karengillian/","terms"=>["karengillian"]},
      "hayden"=>{"path"=>"/data/3tb/pictures/hayden/","terms"=>["hayden"]},
      "chloe"=>{"path"=>"/data/3tb/pictures/chloe/","terms"=>["chloe"]},
    };

    for my $picstar (keys $picturestars){
      my @terms = @{$picturestars->{$picstar}->{terms}};
      my $path = $picturestars->{$picstar}->{path};
      my $foundterm = 0;
      #print "searching keywords: ";
      #print join(", ",@terms);
      #print "\npath: $path\n";
      if($data !~ /send_photo/){
        for my $term (@terms){
          if($data =~ /$term/i){
            $foundterm = 1;
          }
        }
      }
      if($foundterm){
        print "$picstar detected, printing pic\n";
        opendir(my $dh,$path) || die("can't open $path! $!");
        my @dir = readdir($dh);
        print "dir is".scalar(@dir)."\n";
        my $rand = rand(scalar(@dir));
        my $file = $dir[int($rand)];
        while($file =~ /^\.$/ || $file =~ /^\.\.$/){
          #while($file =~ /^\.$/ || $file == ".."){ #werkt anders, even uitzoeken waarom
          print "found . ($file) rand:$rand retrying...\n";
          $rand = rand(scalar(@dir));
          $file = $dir[int($rand)];
        }
        print "Sending pic: $file ($rand)\n";
        $wh->say("send_photo $msg->{receiver} ".$path.$dir[int($rand)]) or die $!;
      }
    }

    if($data =~ /!ascii(.*?)normal/i){
      my $tring = $1;
      $wh->say("msg $msg->{receiver} BOT: $1 => $tring") or die $!;
      $tring =~ s/(.)/ord($1)/eg;
      print "Ascii: $tring\n";
      $wh->say("msg $msg->{receiver} BOT: $1 => $tring") or die $!;
    }
    if($data =~ /\$(.*?)\{(.*?)\}\+\+/){
      my $list = $1;
      my $attr = $2;
      if(!defined($nerdlist->{$list})){
        $nerdlist->{$list} = {};
      }
      if(!defined($nerdlist->{$list}->{$attr})){
        $nerdlist->{$list}->{$attr} = 0;
      }
      $nerdlist->{$list}->{$attr}++;
      $wh->say("msg $msg->{receiver} BOT: ".'$'.$list.'{'.$attr.'} = '.$nerdlist->{$list}->{$attr}) or die $!;
    }
    if($data =~ /\$(.*?)\{(.*?)\}\-\-/){ #GAY KAN In vorige loopje big
      my $list = $1;
      my $attr = $2;
      if(!defined($nerdlist->{$list})){
        $nerdlist->{$list} = {};
      }
      if(!defined($nerdlist->{$list}->{$attr})){
        $nerdlist->{$list}->{$attr} = 0;
      }
      $nerdlist->{$list}->{$attr}--;
      $wh->say("msg $msg->{receiver} BOT: ".'$'.$list.'{'.$attr.'} = '.$nerdlist->{$list}->{$attr}) or die $!;
    }
    if($data =~ /!printstats/i || $data =~ /!stats/i){
      my $stats = Dumper $nerdlist;
      $stats =~ s/\n/ /gm;
      $stats =~ s/\$VAR1 = / /gm;
      $wh->say("msg $msg->{receiver} BOT: stats since $startuptime:") or die $!;
      sleep(0.1);
      for my $stat (sort keys %$nerdlist){
        for my $value (sort keys %$nerdlist{$stat}){
          $wh->say("msg $msg->{receiver} BOT: $stat $value => $nerdlist->{$stat}->{$value}") or die $!;
          sleep(0.5);
        }
      }
    }
    if($data =~ /!time/i){
      my $tijd = time();
      my $localtijd = localtime(time);
      $wh->say("msg $msg->{receiver} BOT: $tijd ($localtijd") or die $!;
    }
    if($data =~ /<3/i){
      $wh->say("msg $msg->{receiver} BOT: Awwh... $msg->{sender} i <3 u 2. Happy day!") or die $!;
    }
    if($data =~ /!me/i){
      $wh->say("msg $msg->{receiver} BOT: Ja dat is dus $msg->{sender} die dat zegt.") or die $!;
    }
    if($data =~ /!currentmusic/i){
      my $music = `mpc status | head -1`;
      $music =~ s/\n/ /gm;
      #$wh->say("msg $msg->{receiver} BOT: Host is currently listening to $music") or die $!;
      $music =~ s/\(/ /gm;
      $music =~ s/\)/ /gm;
      my $musicyt = $music;
      $musicyt =~ s/ /\%20/g;
      my $link = "http://www.youtube.com/results?search_query=$musicyt";
      $link =~ s/%20$//i;
      $link =~ s/\'//i;
      print "trying to get link : $link \n";
      my $yt = `curl -L $link`  or die("can;t do it: $link $!");
      $yt =~ /\=\"\/watch\?(.*?)"/im;
      my $tmp = $1;
      $tmp =~ s/^v=//i;
      my $ytlink = "https://youtu.be/$tmp";
      $wh->say("msg $msg->{receiver} BOT: Host is currently listening to $music: $ytlink (id : $tmp)") or die $!;
    }
    if($data =~ /!yt/i){
      if($data =~ /!yt\s(.*?)normal/i){
        my $music = $1;
        $music =~ s/\n/ /gm;
        $music =~ s/\(/ /gm;
        $music =~ s/\)/ /gm;
        my $musicyt = $music;
        $musicyt =~ s/ /\%20/g;
        my $link = "http://www.youtube.com/results?search_query=$musicyt";
        $link =~ s/%20$//i;
        print "trying to get link : $link \n";
        my $yt = `curl -L $link`  or die("can;t do it: $link $!");
        $yt =~ /\=\"\/watch\?(.*?)"/im;
        my $tmp = $1;
        $tmp =~ s/^v=//i;
        my $ytlink = "https://youtu.be/$tmp";
        $wh->say("msg $msg->{receiver} BOT: Best result for ($music) $ytlink (id : $tmp)") or die $!;
      }else{
        $wh->say("msg $msg->{receiver} BOT: no search arguments given..") or die $!;
      }
    }
    if($data =~ /imgur/i){
      print "imgur link detected\n";
      if($data =~ /https/i){
        $wh->say("msg $msg->{receiver} BOT: httpslink, can't crawl") or die $!;
      }else{
        if($data =~ /(http:\/\/imgur.com\/gallery\/.*?)normal/i){
          my $link = $1;
          my $content = get $link;
          die "Couldn't get $link" unless defined $content;
          $content =~ /og:image.*?"(http:\/\/i.imgur.com\/.*?)\.(.*?)"/i;
          my $imglink = $1;
          my $imgext = $2;
          $wh->say("msg $msg->{receiver} BOT: oke imgor link $link, crawling for imglink $imglink.$imgext") or die $!;
          $time = time;
          `wget $imglink.$imgext -O img/$time.$imgext`;
          $wh->say("send_photo $msg->{receiver} /home/tobias/apps/telegrambot.ontw/img/$time.$imgext") or die $!;
        }elsif($data =~ /(http:\/\/i.imgur.com\/.*?)\.(.*?)normal/i){
          my $imgpath = $1;
          my $ext = $2;
          $wh->say("msg $msg->{receiver} BOT: Direct image, getting image $imgpath.$ext") or die $!;
          $time = time;
          `wget $imgpath.$ext -O img/$time.$ext`;
          $wh->say("send_photo $msg->{receiver} /home/tobias/apps/telegrambot.ontw/img/$time.$ext") or die $!;
        }
        else{
          $wh->say("msg $msg->{receiver} BOT: unknown format") or die $!;
        }
      }
    }
    if($data =~ /!test/i){
      print "oke dit is dus een test\n";
      $wh->say("msg $msg->{receiver} BOT: CreeperBot $version") or die $!;
    }
    if($data =~ /!stopbot/i){
      print "Oke stopping to listen...\n";
      $wh->say("msg $msg->{receiver} BOT: Stopping CreeperBot $version") or die $!;
      $started = 1;
    }
    if($data =~ /!userlist/i){
      print "Printing userlist";
      print Dumper $userlist;
    }
    if($data =~ /!msgcount/i){
      print "Printing messagecount";
      my $msgcnt = Dumper $msgcount;
      $msgcnt =~ s/\n/ /gm;
      #$wh->say("msg $msg->{receiver} BOT: $msgcnt") or die $!;
      my $tring = "";
      if(defined($msgcount->{$msg->{group}})){
        for my $user (keys $msgcount->{$msg->{group}}){
          $tring .= "$user : ".$msgcount->{$msg->{group}}->{$user}." ,";
        }
      }
      $wh->say("msg $msg->{receiver} BOT: $tring") or die $!;
      print Dumper $msgcount;
    }
    if($data =~ /!msgdisect/i || $data =~ /!disectmsg/i){
      $msgdis = Dumper $msg;
      $msgdis =~ s/\n/ /gm;
      $wh->say("msg $msg->{receiver} BOT: $msgdis") or die $!;
    }
    if($data =~ /!info/i){
      $wh->say("msg $msg->{receiver} BOT: meer informatie op http://02.sudodev.net/telegrambot/") or die $!;
    }
    if($data =~ /!ideas/i){
      $wh->say("msg $msg->{receiver} BOT: Welcome back message if gone sooo long (threshold). ideaboard, dbase, ok i'm tired now") or die $!;
    }
  }
  if($data =~ /!startbot/i){
    print "Oke starting to listen...\n";
    #$wh->say("msg $msg->{receiver} BOT: Starting CreeperBot $version") or die $!;
    $started = 1;
  }
  if($data =~ /!quit/i){
    print "Shutting down\n";
    #$wh->say("msg $msg->{receiver} BOT: Quitting") or die $!;
    last READ;
  }
}

$rh->close;
$wh->close or die "pipe execited with $?";

sub parse_msg{
  my $msg = shift;
  $msg =~ s/'/ /g;
  for my $color (keys $colors){
    #print "c: $colors->{$color}| $color\n";
    $msg =~ s/\Q$colors->{$color}\E/$color/g;
  }
  #print "parse_msg count $cnt\n";
  if($msg =~ /^User redr?e?d?b?(.*?)yellow/){
    my $temp = $1;
    $temp =~ s/ /_/g;
    $temp =~ s/red$//;
    print "!! User $temp found \n";
    push(@{$userlist->{users}},$temp);
  }
  if($msg =~ /Chat magenta(.*?)yellow/){
    my $temp = $1;
    $temp =~ s/ /_/g;
    print "!! Chat $temp found \n";
    push(@{$userlist->{groups}},$temp);
  }
  return $msg;
}
sub disect_msg{
  my $msg = shift;
  $msg =~ s/'/ /g;
  $return = {};
  if($msg =~ /normal magenta(.*?)normal redr?e?d?b?(.*?)normal.*? >>> (.*)normal/){
    $return = {
      "group"=>$1,
      "sender"=>$2,
      "message"=>$3,
      "receiver"=>$1,
    };
    $return->{group} =~ s/red$//;
    if(!defined($msgcount->{$return->{group}})){
      $msgcount->{$return->{group}} = {};
      print "!! nieuwe groep count\n";
    }
    if(!defined($msgcount->{$return->{group}}->{$return->{sender}})){
      $msgcount->{$return->{group}}->{$return->{sender}} = 0;
      print "!! nieuwe persoon count\n";
    }
    $msgcount->{$return->{group}}->{$return->{sender}}++;
  }
  elsif($msg =~ /normal redr?e?d?b?(.*?)r?e?d?normal.*? <<< (.*?)normal/){
    $return = {
      "to"=>$1,
      "message"=>$2,
      "receiver"=>$1,
    };
    $return->{to} =~ s/red$//;
    $return->{receiver} =~ s/red$//;
  }
  elsif($msg =~ /normal redr?e?d?b?(.*?)r?e?d?normal.*? >>> (.*?)normal/){
    $return = {
      "from"=>$1,
      "message"=>$2,
      "receiver"=>$1,
    };
    $return->{from} =~ s/red$//;
    $return->{receiver} =~ s/red$//;
  }
  if(defined($return->{receiver})){
    $return->{receiver} =~ s/ /_/g;
  }
  return $return;
}
