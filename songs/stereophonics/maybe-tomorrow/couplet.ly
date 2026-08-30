\version "2.24.0"

\header {
  title = "couplet"
  instrument = "mélodie"
  tagline = ##f
}

\include "couplet-defs.ly"


melody = {
  \clef "treble_8"
  \time 4/4
  \songTempo

  \repeat percent 8   {
  c'16\3 \glissando d'16\3 r16 f'16\2 f'16\2 d'16\3 g'16\2 
  r4 f'16\2 
  ais'16\1 r16 g'16\2 r16 
  |
  }

}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \boldGlissando \tabDurations \melody }
    \new Dynamics { \songbookBeatMarks 1 }
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
    %% MIDI balance, \midi score only - none of this affects the engraving.
    %% Default velocity with no setting is 90/127. midiMinimumVolume pushes a
    %% part up, midiMaximumVolume pulls it down; here the melody sits well
    %% above the rhythm guitar.
    \new TabStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } \melody
    \new TabStaff \with {
      midiMinimumVolume = #0.2
      midiMaximumVolume = #0.8
    } \rythm
    \new DrumStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } { \songbookDrums 8 }
  >>
  \midi {}
}

% touch
