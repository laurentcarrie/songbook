\version "2.24.0"

\header {
  title = "refrain"
  instrument = "guitar"
  tagline = ##f
}

\include "defs.ly"

harmonies = \chordmode { d1:m d1:m c1 c1 }

melody = {
  \time 4/4
  \songTempo

  f'16\3 f'16\3 f'16\3 f'16\3 
  f'16\3 \deadNote f'16\3 \deadNote f'16\3 \deadNote f'16\3 
  <f'\3 a'\2>16 <f'\3 a'\2>16 <f'\3 a'\2>16 <f'\3 a'\2>16 
  <f'\3 a'\2>16 \deadNote <f'\3 a'\2>16 \deadNote <f'\3 a'\2>16 \deadNote <f'\3 a'\2>16
  |
  < a'\2  d''\1>16 < a'\2  d''\1>16 < a'\2  d''\1>16 < a'\2  d''\1>16 
  < a'\2  d''\1>16 \deadNote < a'\2  d''\1>16 \deadNote < a'\2  d''\1>16 \deadNote < a'\2  d''\1>16
  < a'\2  d''\1>16 < a'\2  d''\1>16 \deadNote < a'\2  d''\1>16 \deadNote < a'\2  d''\1>16 
  < a'\2  d''\1>16 < a'\2  d''\1>16 \deadNote < a'\2  d''\1>16 \deadNote < a'\2  d''\1>16 
  |
  c8\6 c8\6 <dis'\3 g'\2>4
  c8\6 c16\6 c16\6
  g,16\6 g,16\6 g,16\6 g,16\6
  |
  c8\6 c8\6 <dis'\3 g'\2>4
  c8\6 c16\6 c16\6
  g,16\6 g,16\6 g,16\6 g,16\6
  |


}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff \with {
      stringTunings = \dropD
      instrumentName = \dropDLabel
    } {
      \textMark \markup \italic "6th string dropped to D"
      \boldGlissando \tabDurations \melody
    }
    \new Dynamics { \songbookBeatMarks 4 }
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
    \new TabStaff \with {
      stringTunings = \dropD
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } \melody
    \new DrumStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } { \songbookDrums 4 }
  >>
  \midi {}
}
