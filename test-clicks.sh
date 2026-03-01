#!/bin/bash
set -e

SONG_DIR=${1:?Usage: $0 <song-dir>}

python3 -c "
import yaml, numpy as np
from scipy.io import wavfile

with open('${SONG_DIR}/clicks.yml') as f:
    ticks = yaml.safe_load(f)['ticks']

sr = 44100
dur = ticks[-1] + 1.0
samples = np.zeros(int(dur * sr), dtype=np.float32)
t = np.arange(int(0.01 * sr)) / sr
click = 0.8 * np.sin(2 * np.pi * 1000 * t) * np.linspace(1, 0, len(t))
for tick in ticks:
    idx = int(tick * sr)
    end = min(idx + len(click), len(samples))
    samples[idx:end] += click[:end - idx]
wavfile.write('/tmp/ticks.wav', sr, (np.clip(samples, -1, 1) * 32767).astype(np.int16))
"

ffmpeg -y -i /tmp/ticks.wav /tmp/ticks.mp3 2>/dev/null
ffmpeg -y -i "${SONG_DIR}/song.mp3" -i /tmp/ticks.mp3 \
  -filter_complex amix=inputs=2:duration=longest "${SONG_DIR}/overlay.mp3" 2>/dev/null
rm /tmp/ticks.wav /tmp/ticks.mp3

echo "Created ${SONG_DIR}/overlay.mp3"
