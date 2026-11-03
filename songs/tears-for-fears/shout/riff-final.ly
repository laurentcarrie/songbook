\version "2.24.0"

%% Number of 4/4 bars covered by the beat marks and the MIDI drums.
nbbars = 2

\header {
  title = "riff final"
  instrument = "mélodie"
  tagline = ##f
}

\include "defs.ly"

finalHarmonies = \chordmode { fis1:m }

%% TODO: placeholder - one bar on the F#m root, replace with the real riff.
melody = {
  \clef "treble_8"
  \time 4/4
  \songTempo
  fis8\4 e8\4 fis,8\6 fis,8\6      e8\4 cis8\5 fis,8\6 fis,8\6
  |
  d8\4 cis8\5 fis,8\6 fis,8\6
  a,8\5 gis,8\6 fis,8\6 fis,8\6
  |

}

\score {
  <<
    \new ChordNames \finalHarmonies
    \new TabStaff { \tabDurations \melody }
    \new Dynamics { \songbookBeatMarks \nbbars }
    \new Dynamics { \songbookBeatShade \nbbars }
  >>
  \layout {}
}

\score {
  \unfoldRepeats <<
    \new TabStaff \melody
    \new DrumStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } { \songbookDrums \nbbars }
  >>
  \midi {}
}
