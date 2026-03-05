# Songbook Project

## Beat Detection Pipeline (clicks.yml)

Generate `clicks.yml` (beat timestamps) from a song's `clicks.mp3`.

### Prerequisites
- Python with `librosa`, `pyyaml`, `numpy`, `scipy`
- `ffmpeg` for WAV to MP3 conversion

### Steps

1. **Beat detection** from `song.mp3`:
   ```python
   import librosa
   y, sr = librosa.load("song.mp3", sr=None)
   tempo, beats = librosa.beat.beat_track(y=y, sr=sr, bpm=BPM, tightness=100, trim=False, start_bpm=BPM)
   ticks = list(librosa.frames_to_time(beats, sr=sr))
   ```
   - Adjust `bpm` to the song's actual BPM
   - `tightness=100` gives strict tempo adherence (avoids detecting eighth notes)

2. **Trim pickup notes** at the start — remove ticks before the groove starts:
   ```python
   beat = 60.0 / BPM
   while len(ticks) > 2 and abs(ticks[1] - ticks[0] - beat) / beat > 0.2:
       ticks = ticks[1:]
   ```

3. **Fill missing beats** — interpolate gaps > 0.85s:
   ```python
   filled = []
   for i in range(len(ticks)):
       filled.append(ticks[i])
       if i < len(ticks) - 1:
           gap = ticks[i+1] - ticks[i]
           if gap > 0.85:
               n = max(2, round(gap / beat))
               step = gap / n
               for j in range(1, n):
                   filled.append(float(ticks[i] + j * step))
   ```

4. **Save clicks.yml** — IMPORTANT: convert numpy floats to plain `float()`:
   ```python
   import yaml
   with open("clicks.yml", "w") as f:
       yaml.dump({"ticks": [float(t) for t in filled]}, f, default_flow_style=False)
   ```

### Format (must match `model::ClicksDefinition` in band-songbook crate)
```yaml
ticks:
- 0.418
- 1.033
- 1.649
...
```

### Verification
Use `test-clicks.sh` to overlay clicks on the song:
```bash
./test-clicks.sh songs/<artist>/<song>
# then play <song-dir>/overlay.mp3
```

### Dani California reference (96 BPM)
- 449 beats, median delta 0.627s, 0 outliers
