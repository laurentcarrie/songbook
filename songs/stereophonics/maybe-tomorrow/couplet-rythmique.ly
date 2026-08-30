\version "2.24.0"

\header {
  title = "couplet"
  instrument = "guitare rythmique"
  tagline = ##f
}

\include "couplet-defs.ly"

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \boldGlissando \tabDurations \rythm }
    \new Dynamics { \songbookBeatMarks 4 }
    % \new DrumStaff { \songbookDrums 4 }
  >>
  \layout {}
}


\score {
  \unfoldRepeats <<
    \new TabStaff \rythm
    %% Louder than the guitar: raises the drum note-on velocity from 90 to 123
    %% out of 127. Only meaningful in the \midi score - it does nothing to the
    %% engraving. Lower midiMinimumVolume to soften it.
    \new DrumStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } { \songbookDrums 8 }
  >>
  \midi {}
}

