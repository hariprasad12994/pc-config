#!/usr/bin/env bash
# Lists explicitly-installed apt packages on stdout - redirect it wherever you
# want the snapshot. Writes nowhere by itself, so there is no tracked dump to go
# stale the way out/ did.
set -e
apt-mark showmanual
