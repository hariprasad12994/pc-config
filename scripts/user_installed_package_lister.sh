#!/usr/bin/env bash
# Lists explicitly-installed packages on stdout - redirect it wherever you want
# the snapshot. Writes nowhere by itself, so there is no tracked dump to go
# stale the way out/ did.
set -e

. /etc/os-release

case "$ID" in
    arch|manjaro)   pacman -Qqe ;;
    ubuntu|debian)  apt-mark showmanual ;;
    *) echo "Unsupported distro: $ID" >&2; exit 1 ;;
esac
