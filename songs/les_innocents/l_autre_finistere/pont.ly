\version "2.24.0"

\header {
  title = "pont"
  instrument = "mélodie"
  tagline = ##f
}

\include "pont-defs.ly"


melody = {
  \clef "treble_8"
  \time 4/4
  \tempo 4 = 80

  dis'2.\2 \acciaccatura dis'8\2 f'8\2 dis'8\2 |
  d'2\2 ~ d'8.\2 d'16\2 d'16\2 e'16\2 fis'16\1 g'16\1 |
  fis'2.\1 dis'8\2 d'8\2 |
  d'2.\2 c'8\3 d'8\2 |
  %% mesure 5
  dis'2.\2 \acciaccatura dis'8\2 f'8\2 dis'8\2 |
  d'2\2 ~ d'8.\2 d'16\2 d'16\2 e'16\2 fis'16\1 g'16\1 |
  fis'2.\1 g'8\1 a'8\1 |
  d'1\2 |



}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \boldGlissando \tabDurations \melody }
    % \new TabStaff { \boldGlissando \tabDurations \rythm }
  >>
  \layout {}
}

%% Separate score for the MIDI: \repeat volta is only drawn as repeat barlines,
%% it is not played back. \unfoldRepeats expands it, so the MIDI matches what
%% the score means. Keep it out of the \layout score, or the repeat would be
%% printed written out.
\score {
  \unfoldRepeats <<
    \new TabStaff \melody
    \new TabStaff \rythm
  >>
  \midi {}
}
