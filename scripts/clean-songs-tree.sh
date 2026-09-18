#!/usr/bin/env bash
#
# Remove build leftovers from the songs/ tree.
#
# What gets removed: files LilyPond and the local editor workflow drop next to
# the sources - <name>.pdf, <name>.midi, lilypond-tmp-*.pdf, *.tmp. The real
# build writes to sandbox/ and delivery/ instead, so nothing here is a source.
#
# Two rules keep this safe:
#
#   1. A file tracked by git is never removed. Several working files under
#      songs/ are committed on purpose (*.yml.broken, *.strudel, song.html,
#      and even a solo.ly~), so extension alone is not enough to judge.
#   2. song.mp3 is never removed, not even with --audio. Those recordings are
#      not in the repo; the only copy besides the local one lives on S3, and
#      `make upload` deletes the remote songs/ before re-uploading - which is
#      why the Makefile has a check-mp3 guard. Losing one locally is real data
#      loss. Recover with `make download-prod`.
#
# Derived audio (overlay.mp3, clicks.mp3, ...) is left alone unless --audio is
# given; it is cheap to rebuild with ./test-clicks.sh but takes a while.
#
# Dry run by default. Pass -f to actually delete.

set -uo pipefail

cd "$(dirname "$(readlink -f "$0")")/.." || exit 1
songs=songs

force=0
audio=0
for arg in "$@"; do
  case $arg in
    -f|--force) force=1 ;;
    --audio)    audio=1 ;;
    -h|--help)
      sed -n '2,/^set /p' "$0" | sed 's/^# \?//; $d'
      echo "usage: $0 [-f|--force] [--audio]"
      exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

[ -d "$songs" ] || { echo "no $songs/ directory here" >&2; exit 1; }

# Build the candidate list.
mapfile -t candidates < <(
  find "$songs" -type f \( \
      -name '*.pdf' -o -name '*.midi' -o -name '*.tmp' -o -name 'lilypond-tmp-*' \
    \) -print
  if [ "$audio" = 1 ]; then
    find "$songs" -type f -name '*.mp3' ! -name 'song.mp3' -print
  fi
)

kept_tracked=0
declare -a doomed=()
for f in "${candidates[@]:-}"; do
  [ -n "$f" ] || continue
  # Rule 2, belt and braces: song.mp3 can never end up here.
  case "$(basename "$f")" in song.mp3) continue ;; esac
  # Rule 1: never touch anything git knows about.
  if git ls-files --error-unmatch -- "$f" >/dev/null 2>&1; then
    kept_tracked=$((kept_tracked + 1))
    continue
  fi
  doomed+=("$f")
done

n=${#doomed[@]}
if [ "$n" -eq 0 ]; then
  echo "nothing to clean under $songs/"
  [ "$kept_tracked" -gt 0 ] && echo "($kept_tracked tracked file(s) skipped)"
  exit 0
fi

total=0
for f in "${doomed[@]}"; do
  sz=$(stat -c %s "$f" 2>/dev/null || echo 0)
  total=$((total + sz))
  if [ "$force" = 1 ]; then
    rm -f -- "$f" && echo "removed  $f"
  else
    echo "would remove  $f"
  fi
done

human=$(numfmt --to=iec --suffix=B "$total" 2>/dev/null || echo "$total bytes")
if [ "$force" = 1 ]; then
  echo "--- removed $n file(s), $human"
else
  echo "--- $n file(s), $human - dry run, pass -f to delete"
fi
[ "$kept_tracked" -gt 0 ] && echo "--- $kept_tracked tracked file(s) skipped (never removed)"
exit 0
