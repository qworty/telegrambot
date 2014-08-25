#!/usr/bin/perl
use IPC::Open2;
use IO::Handle;
$tgpath = "telegram";
$|++;

open my $pipe, '|-',$tgpath, @arguments or die $!;
sleep(3);
#$pipe->say("send_photo #Gebrabbel_#Magic_#FreeTherapy /home/tobias/apps/telegrambot/vomitchan2.jpg") or die $!;
#$pipe->flush();
$count = 1;
while(1){
  if($count % 30 == 0){
    print "Going to print something...\n";
    $pipe->say("msg #Gebrabbel_#Magic_#FreeTherapy BOT: $count pipe test") or die $!;
    $pipe->flush();
  }
  $count++;
  sleep(1);
  print $count."\n";
}
$pipe->close or die "pipe exited with code $?"; 
