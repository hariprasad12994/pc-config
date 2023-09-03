#!/bin/bash

# pacman -Qqe | grep -v "$(awk '{print $1}' /desktopfs-pkgs.txt)" >\
# ../out/user_installed_packages.txt
pacman -Qqe > ../out/user_installed_packages.txt
