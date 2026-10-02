\version "2.24.0"

\header {
  title = "intro"
  instrument = "mélodie, capo 4"
  tagline = ##f
}

\include "macros.ly"

%% Capo on fret 4: raise every open string by a major third, so the tab shows
%% frets counted from the capo while the notes keep their sounding pitch.
capoTuning = #(map (lambda (p) (ly:pitch-transpose p (ly:make-pitch 0 2 0))) guitar-tuning)

melody = {
  \clef "treble_8"
  \time 4/4
  \tempo 4 = \songtempo
  b1 |
}

\score {
  \new TabStaff \with { stringTunings = \capoTuning } { \melody }
  \layout {}
}

\score {
  \new TabStaff \with { stringTunings = \capoTuning } { \melody }
  \midi {}
}
