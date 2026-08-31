#!/usr/bin/env bash
# Lists installed snaps on stdout - redirect it wherever you want the snapshot.
set -e
command -v snap >/dev/null || { echo "snap not installed." >&2; exit 1; }
snap list
