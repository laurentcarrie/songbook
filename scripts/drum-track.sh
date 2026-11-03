#!/usr/bin/env bash
#
# Make a plain drum track to play along with, and play it.
#
# Kick on beats 1 and 3, snare on beats 2 and 4, closed hi-hat on every eighth
# note, in 4/4, after two beats of silence and a one-bar count-in (snare on every beat plus the "and" of 4) that is not
# counted in <bars>. Every second bar ends on a light fill (a second
# snare hit on the "and" of 4). Writes a LilyPond file, renders its MIDI with lilypond, then
# the audio with fluidsynth, encodes an mp3 with ffmpeg and plays it with mpv.
#
#   scripts/drum-track.sh 83 8                # 8 bars at 83 BPM, files in a temp dir
#   scripts/drum-track.sh 83 8 ~/drums        # keep the files in ~/drums
#   scripts/drum-track.sh 83 8 -v 150         # volume in percent (default 100), applied to the mp3
#   scripts/drum-track.sh 83 8 -- --loop      # anything after `--` goes to mpv
#
# SOUNDFONT overrides the soundfont.

set -uo pipefail

SOUNDFONT=${SOUNDFONT:-/usr/share/sounds/sf2/FluidR3_GM.sf2}

die() { echo "drum-track: $*" >&2; exit 1; }

mine=(); theirs=(); seen_sep=0; volume=100
while [ $# -gt 0 ]; do
  a=$1; shift
  if [ "$seen_sep" = 0 ] && [ "$a" = "--" ]; then seen_sep=1; continue; fi
  if [ "$seen_sep" = 1 ]; then theirs+=("$a"); continue; fi
  case $a in
    -v) [ $# -gt 0 ] || die "-v needs a percentage"; volume=$1; shift ;;
    *) mine+=("$a") ;;
  esac
done
{ [ ${#mine[@]} -eq 2 ] || [ ${#mine[@]} -eq 3 ]; } \
  || die "usage: $(basename "$0") <bpm> <bars> [outdir] [-v percent] [-- mpv args...]"

bpm=${mine[0]}
bars=${mine[1]}
[[ $bpm =~ ^[0-9]+$ ]] && [ "$bpm" -ge 20 ] && [ "$bpm" -le 400 ] || die "bpm must be an integer between 20 and 400: $bpm"
[[ $volume =~ ^[0-9]+$ ]] && [ "$volume" -ge 1 ] && [ "$volume" -le 1000 ] || die "volume must be an integer percentage between 1 and 1000: $volume"
[[ $bars =~ ^[0-9]+$ ]] && [ "$bars" -ge 1 ] || die "bars must be a positive integer: $bars"

[ -r "$SOUNDFONT" ] || die "soundfont not readable: $SOUNDFONT (set SOUNDFONT=...)"
for tool in lilypond fluidsynth ffmpeg mpv; do
  command -v "$tool" >/dev/null || die "$tool is not installed"
done

if [ ${#mine[@]} -eq 3 ]; then
  outdir=${mine[2]}
  mkdir -p -- "$outdir" || die "cannot create $outdir"
else
  outdir=$(mktemp -d) || die "cannot create a temp dir"
fi
name=drums-${bpm}bpm-${bars}bars
ly=$outdir/$name.ly

# Every second bar ends on a light fill: beat 4 gets a second snare hit on the
# "and", everything else stays. A trailing odd bar gets none.
body=""
for ((i = 1; i <= bars; i++)); do
  if [ $((i % 2)) -eq 0 ]; then last="sn8 sn"; else last="sn4"; fi
  body+="  << { hh8 hh hh hh hh hh hh hh } \\\\ { bd4 sn bd $last } >>"$'\n'
done

cat > "$ly" <<LY
\\version "2.24.0"

\\header { tagline = ##f }

track = \\drummode {
  \\tempo 4 = $bpm
  \\time 4/4
  %% Two beats of silence first: the audio device needs a moment to wake up
  %% and would swallow the first hit of the count-in.
  r2
  sn4 sn sn sn8 sn
$body}

\\score {
  \\new DrumStaff \\track
  \\layout {}
  \\midi {}
}
LY

# --loglevel=ERROR keeps the output quiet; the pdf is a by-product we do not need.
(cd "$outdir" && lilypond --loglevel=ERROR -o "$name" "$name.ly") || die "lilypond failed on $ly"
midi=$outdir/$name.midi
[ -f "$midi" ] || die "lilypond wrote no $midi"

wav=$outdir/$name.wav
mp3=$outdir/$name.mp3
fluidsynth -ni -q -F "$wav" -r 44100 "$SOUNDFONT" "$midi" >/dev/null 2>&1 \
  && [ -s "$wav" ] || die "fluidsynth wrote no audio for $midi"
# Above 100% the peaks would clip, so a limiter follows the gain.
ffmpeg -y -loglevel error -i "$wav" -af "volume=$(awk -v v="$volume" 'BEGIN{printf "%.3f", v/100}'),alimiter=limit=0.97" -codec:a libmp3lame -q:a 2 "$mp3" || die "ffmpeg failed on $wav"
rm -f "$wav"

echo "drum-track: $mp3"
exec mpv --no-video --really-quiet "${theirs[@]}" "$mp3"
