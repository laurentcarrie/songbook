#!/usr/bin/env python3
"""Check the mp3 under prod/songs in the bucket against the songs in git.

The mp3 are not in git: they reach the bucket only through `make upload-mp3`, and nothing else produces or
checks them. The CI packs whatever is there into delivery-mp3.tar.gz, so this step makes it fail instead:

  - missing: a song.yml with `has_mp3: true` and no <song dir>/song.mp3 in the bucket;
  - orphan:  an mp3 in the bucket under a song directory that has no song.yml in git any more
             (the upload to prod leaves the mp3 alone, so a deleted song keeps its audio).

Warning only: a song.mp3 in the bucket for a song that does not say `has_mp3: true`.

Needs BUCKET and AWS credentials. Prints no bucket name. For a test without AWS, pass --keys <json file>, a list of
the object keys (prod/songs/...).
"""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

SONGS = Path(os.environ.get("SONGS_DIR", "songs"))
PREFIX = "prod/songs/"
HAS_MP3 = re.compile(r"^\s*has_mp3:\s*true\b", re.M)


def keys_from_bucket(bucket):
    out = subprocess.run(
        ["aws", "s3api", "list-objects-v2", "--bucket", bucket, "--prefix", PREFIX,
         "--query", "Contents[?ends_with(Key, '.mp3')].Key", "--output", "json"],
        check=True, capture_output=True, text=True).stdout
    return json.loads(out) or []


def main():
    if "--keys" in sys.argv:
        keys = json.load(open(sys.argv[sys.argv.index("--keys") + 1]))
    else:
        bucket = os.environ.get("BUCKET")
        if not bucket:
            sys.exit("BUCKET is not set")
        keys = keys_from_bucket(bucket)

    # song dir (relative to songs/, e.g. "u2/song_for_someone") -> mp3 names present in the bucket
    remote = {}
    for k in keys:
        rel = k[len(PREFIX):] if k.startswith(PREFIX) else k
        d, _, name = rel.rpartition("/")
        remote.setdefault(d, set()).add(name)

    want, known = set(), set()
    for yml in sorted(SONGS.glob("*/*/song.yml")):
        d = str(yml.parent.relative_to(SONGS))
        known.add(d)
        if HAS_MP3.search(yml.read_text(encoding="utf-8")):
            want.add(d)

    missing = sorted(d for d in want if "song.mp3" not in remote.get(d, ()))
    orphans = sorted(f"{d}/{n}" for d, names in remote.items() if d not in known for n in sorted(names))
    unexpected = sorted(d for d in known - want if "song.mp3" in remote.get(d, ()))

    print(f"songs with has_mp3: {len(want)}, mp3 in the bucket: {len(keys)}")
    for d in unexpected:
        print(f"warning: {d}/song.mp3 is in the bucket but song.yml does not say has_mp3: true")
    for d in missing:
        print(f"MISSING: {d}/song.mp3 (has_mp3: true, not in the bucket) - make upload-mp3-prod")
    for p in orphans:
        print(f"ORPHAN:  {p} (no song.yml for it in git)")
    if missing or orphans:
        sys.exit(1)
    print("mp3 check ok")


if __name__ == "__main__":
    main()
