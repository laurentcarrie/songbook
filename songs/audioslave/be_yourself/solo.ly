\version "2.24.0"

%% Number of 4/4 bars covered by the beat marks and the MIDI drums.
nbbars = 16

\header {
  title = "solo"
  instrument = "guitare"
  tagline = ##f
}

\include "../../songbook.ily"

#(if (file-exists? "macros.ly")
     (ly:parser-include-string "\\include \"macros.ly\"")
     (ly:parser-define! 'songtempo 116))

songTempo = { \tempo 4 = \songtempo }

harmonies = \chordmode {
  \repeat unfold 4 { b1:m d1 g1 e1:m }
}

%% TODO: transcribe the solo. Full-bar rests as a placeholder.
melody = {
  \clef "treble_8"
  \time 4/4
  \songTempo
  |
  b,4\5 cis4\5 d4\5 e4\4
  |
  fis4\4 e4\4 d4\5 cis4\5
  |
  b,4\5 cis4\5 d4\5 e4\4
  |
  d4\5 cis4\5 b,4\5 a,4\5
  |
  b,4\5 cis4\5 d4\5 e4\4
  |
  fis4\4 g4\4 fis4\4 g4\4
  |
  a4\3 g4\4 fis4\4 e4\4
  |
  fis4\4 fis4\4 fis4\4 fis4\4
  |
  \repeat percent 3 {
  a16\4 (b16\4) b8\4 b8\4 \deadNote {b16\4} \deadNote {b16\4}
  d'16\3 b16\4 b8\4 b8\4 \deadNote {b16\4} \deadNote {b16\4}
  |
  }
  |
  d'8\3 e'8\3 fis'8\2 a'8\2
  fis'8\2 e'8\3 d'8\3 b8\4
  |
  \repeat percent 2 {
  a16\4 (b16\4) b8\4 b8\4 \deadNote {b16\4} \deadNote {b16\4}
  d'16\3 (e'16\3) e'8\3 e'8\3 \deadNote {e'16\3} \deadNote {e'16\3}  
  }
  |
    b'16\2\co^ cis''16\2 e''8\1
}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \tabDurations \melody }
    \new Dynamics { \songbookBeatMarks \nbbars }
    \new Dynamics { \songbookBeatShade \nbbars }
  >>
  \layout {}
}

\score {
  \unfoldRepeats <<
    \new TabStaff \melody
    %% MIDI balance, \midi score only. Default velocity is 90/127.
    \new DrumStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } { \songbookDrums \nbbars }
  >>
  \midi {}
}
