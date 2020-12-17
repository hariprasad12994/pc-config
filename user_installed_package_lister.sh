#!/bin/bash

pacman -Qqe | grep -v "$(awk '{print $1}' /desktopfs-pkgs.txt)" > packages_1.txt
