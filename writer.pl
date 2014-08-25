#!/usr/bin/perl
use IPC::Open2;
use IO::Handle;
$tgpath = "telegram";

open my $pipe, '|-',$tgpath, @arguments or die $!;
while(-e "running.bot"){
  if(-e "msg/vomitchan"){
    print "vomitchan detected, printing pic\n";
    $pipe->say("send_photo #Gebrabbel_#Magic_#FreeTherapy /home/tobias/apps/telegrambot/vomitchan2.jpg") or die $!;
    $pipe->flush();
    `rm msg/vomitchan`;
  }
  if(-e "msg/kakbar"){
    print "Kak bar detected \n";
    $pipe->say("msg #Gebrabbel_#Magic_#FreeTherapy BOT:je bent zelf kak") or die $!;
    $pipe->flush();
    `rm msg/kakbar`;
  }
  if(-e "msg/imgur"){
    print "Fucking lui imgurlink\n";
    $pipe->say("msg #Gebrabbel_#Magic_#FreeTherapy BOT:Oke nu moet ik dan t plaatje downloaden en dan printen hier") or die $!;
    $pipe->flush();
    `rm msg/imgur`;
  }
}
$pipe->close or die "pipe exited with code $?"; 

