\version "2.24.0"

\header {
  title = "pont"
  instrument = "guitare rythmique"
  tagline = ##f
}

\include "pont-defs.ly"


\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \boldGlissando \tabDurations \rythm }
  >>
  \layout {}
}

%% Separate score for the MIDI: \repeat volta is only drawn as repeat barlines,
%% it is not played back. \unfoldRepeats expands it, so the MIDI matches what
%% the score means. Keep it out of the \layout score, or the repeat would be
%% printed written out.
\score {
  \unfoldRepeats <<
    \new TabStaff \rythm
  >>
  \midi {}
}
