#!/bin/bash
set -e

rm -rf sandbox delivery

band-songbook --srcdir songs --sandbox sandbox --delivery delivery --settings songs/settings.yml --pattern patty

solo_dir=$(find sandbox -name 'solo.ly' -printf '%h\n' -quit 2>/dev/null || find sandbox -name 'solo.ly' -exec dirname {} \; | head -1)

if [ -z "$solo_dir" ]; then
    echo "Error: solo.ly not found in sandbox"
    exit 1
fi

cd "$solo_dir"
strudel-of-lilypond solo.ly
open solo.html
