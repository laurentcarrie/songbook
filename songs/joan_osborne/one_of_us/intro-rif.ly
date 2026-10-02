\version "2.24.0"

\header {
  title = "intro"
  instrument = "mélodie, capo 4"
  tagline = ##f
}

\include "defs.ly"


melody = {
  \time 4/4
  \songTempo
  \partial 4
  <gis'\1 dis'\2>8 ais'8\1 \bar "||"
  b'8\1 gis8\4 <dis'\2 b\3>8 fis8\4 e8\5 <dis'\2 b\3>8 <e'\2 b\3>8 <fis'\2 b\3>8 |
  b,8\6 dis8\5 fis8\4 b8\3
  \tuplet 3/2 { <b\3 fis\4>8( cis'8\3) fis'8\2 }
  gis'8\1 ais'8\1 \bar "||"
}

\score {
  <<
    \new TabStaff \with { stringTunings = \capoTuning } { \tabDurations \melody }
    \new Dynamics { \partial 4 s4^\markup { \with-color #red \bold "✖" } \songbookBeatMarks 2 }
  >>
  \layout {}
}

%% Separate score for the MIDI, kept out of the \layout score.
\score {
  \unfoldRepeats \new TabStaff \with { stringTunings = \capoTuning } { \melody }
  \midi {}
}
