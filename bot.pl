#!/usr/bin/perl
use IPC::Open2;
use IO::Handle;
$tgpath = "telegram";

open my $pipe, '|-',$tgpath, @arguments or die $!;
open2(my $readfh, my $writefh, $tgpath, @arguments) or die $!;
my $data = readline $readfh or die $!;
while($data = readline $readfh){
  print ".";
  print $data;
  if($data =~ /kakbar/i){
    $pipe->say("msg #Gebrabbel_#Magic_#FreeTherapy ja kakbar leuk hoor kakbar ") or die $!;
    $pipe->flush();
    print "oh man kakbar\n";
  }
  if($data =~ /vomitchan/i){
    print "vomitchan detected, printing pic";
    $pipe->say("send_photo #Gebrabbel_#Magic_#FreeTherapy /home/tobias/apps/telegrambot/vomitchan2.jpg") or die $!;
    $pipe->flush();
  }
}
#$pipe->close or die "pipe exited with code $?"; 
$readfh->close;
$writefh->close or die "pipe execited with $?";
