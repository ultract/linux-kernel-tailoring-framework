#!/bin/bash

if [ -n "$(sudo journalctl -p 3 | grep "pulseaudio" | grep "alsa-source.c" | grep " bug ")" ];then
        echo "journalctl: alsa-source.c Error"
fi

if [ -n "$(sudo journalctl -p 3 | grep "Failed to call clock_adjtime(): Function not implemented")" ];then
        echo "journalctl: systemd-timesyncd Error"
fi

if [ -n "$(sudo journalctl -p 3 | grep "cannot open kernel log (/proc/kmsg)")" ];then
        echo "journalctl: rsyslogd's imklog Error"
fi

if [ -n "$(sudo journalctl -p 3 | grep "Failed to start Daily apt download activities.")" ];then
        echo "journalctl: Daily apt download Error"
fi

if [ -n "$(sudo journalctl -p 3 | grep "Failed to start Daily apt upgrade and clean activities.")" ];then
        echo "journalctl: Daily apt upgrade and clean Error"
fi

if [ -n "$(sudo journalctl -p 3 | grep "Failed to start Update UTMP about System Boot/Shutdown.")" ];then
        echo "journalctl: UTMP Error"
fi

if [ -n "$(sudo journalctl -p 3 | grep "Unrecoverable failure in required component org.gnome.Shell.desktop")" ];then
        echo "journalctl: gnome-session-binary Error"
fi

