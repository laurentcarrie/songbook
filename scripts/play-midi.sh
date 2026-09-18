#!/usr/bin/env bash
#
# Listen to a LilyPond score without going through the editor.
#
# Takes a .midi, a .ly, or a song directory, renders the MIDI to audio with
# fluidsynth, and plays the result with mpv.
#
# Why render instead of playing MIDI live: the live path (a resident fluidsynth
# on an ALSA sequencer port, fed by VSLilyPond or aplaymidi) depends on the
# ALSA port, on PipeWire routing and on VS Code's midiPlayback.output setting -
# three things that break independently and silently. Rendering to a file and
# handing it to mpv depends on none of them, and gives you mpv's controls:
# seek, pause, and --speed for working out a riff slowly.
#
#   scripts/play-midi.sh songs/les_innocents/l_autre_finistere/pont.ly
#   scripts/play-midi.sh songs/les_innocents/l_autre_finistere      # picks a .ly
#   scripts/play-midi.sh .../pont.midi -- --speed=0.75 --start=0:04
#
# Anything after `--` is passed to mpv. SOUNDFONT overrides the soundfont.

set -uo pipefail

repo=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)
SOUNDFONT=${SOUNDFONT:-/usr/share/sounds/sf2/FluidR3_GM.sf2}

die() { echo "play-midi: $*" >&2; exit 1; }

# Split args at `--`: ours before, mpv's after.
mine=(); theirs=(); seen_sep=0
for a in "$@"; do
  if [ "$seen_sep" = 0 ] && [ "$a" = "--" ]; then seen_sep=1; continue; fi
  if [ "$seen_sep" = 1 ]; then theirs+=("$a"); else mine+=("$a"); fi
done
[ ${#mine[@]} -eq 1 ] || die "usage: $(basename "$0") <file.ly|file.midi|song-dir> [-- mpv args...]"
target=${mine[0]}
[ -e "$target" ] || die "no such file or directory: $target"
[ -r "$SOUNDFONT" ] || die "soundfont not readable: $SOUNDFONT (set SOUNDFONT=...)"
command -v fluidsynth >/dev/null || die "fluidsynth is not installed"
command -v mpv        >/dev/null || die "mpv is not installed"

# A directory: take its only .ly with a \score, or ask the user to be explicit.
if [ -d "$target" ]; then
  mapfile -t scored < <(grep -lE '^[^%]*\\score' "$target"/*.ly 2>/dev/null)
  [ ${#scored[@]} -gt 0 ] || die "no .ly with a \\score under $target"
  if [ ${#scored[@]} -gt 1 ]; then
    echo "play-midi: several scores in $target, pick one:" >&2
    printf '  %s\n' "${scored[@]}" >&2
    exit 2
  fi
  target=${scored[0]}
fi

case $target in
  *.midi|*.mid) midi=$target ;;
  *.ly|*.ily)
    midi=${target%.*}.midi
    # A definitions file has no \score, so it produces no MIDI of its own.
    grep -qE '^[^%]*\\score' -- "$target" \
      || die "$(basename "$target") has no \\score - point me at the score that includes it"
    if [ ! -f "$midi" ] || [ "$target" -nt "$midi" ]; then
      echo "play-midi: $(basename "$midi") is missing or stale, compiling" >&2
      "$repo/tools/lilypond-inplace" --loglevel=WARNING "$(readlink -f "$target")" \
        || die "lilypond failed on $target"
    fi ;;
  *) die "expected a .ly or a .midi, got: $target" ;;
esac
[ -f "$midi" ] || die "no MIDI produced for $target"

tmp=$(mktemp -d) || die "cannot create a temp directory"
trap 'rm -rf "$tmp"' EXIT
wav=$tmp/$(basename "${midi%.*}").wav

fluidsynth -ni -F "$wav" "$SOUNDFONT" "$midi" >/dev/null 2>&1 \
  || die "fluidsynth failed to render $midi"
[ -s "$wav" ] || die "fluidsynth produced no audio from $midi"

echo "play-midi: $(basename "$midi")"
mpv --no-video "${theirs[@]+"${theirs[@]}"}" "$wav"
