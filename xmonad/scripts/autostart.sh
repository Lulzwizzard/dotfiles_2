#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

#Set your native resolution IF it does not exist in xrandr
#More info in the script
#run $HOME/.xmonad/scripts/set-screen-resolution-in-virtualbox.sh

#Find out your monitor name with xrandr or arandr (save and you get this line)
#xrandr --output VGA-1 --primary --mode 1360x768 --pos 0x0 --rotate normal
#xrandr --output DP2 --primary --mode 1920x1080 --rate 60.00 --output LVDS1 --off &
#xrandr --output LVDS1 --mode 1366x768 --output DP3 --mode 1920x1080 --right-of LVDS1
#xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off

#if [ "$status" = "" ]
#then

#elif [ "$status" != "disconnected" ]
#then
     #xrandr  --output eDP1 --off --output DP2-1 --primary --mode 3440x1440 --pos 0x0 --rotate normal
#fi



(sleep 2; run $HOME/.config/polybar/launch.sh) &

#change your keyboard if you need it
#setxkbmap -layout bezzzz

#cursor active at boot
xsetroot -cursor_name left_ptr &



#starting utility applications at boot time
#run nm-applet &
#run xfce4-power-manager &
#run volumeicon &
#numlockx on &
xlayoutdisplay -d 108 &
blueberry-tray &
picom --config $HOME/.xmonad/scripts/picom.conf &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/xfce4/notifyd/xfce4-notifyd &
albert & 
dropbox &
nextcloud &
nitrogen --restore &
