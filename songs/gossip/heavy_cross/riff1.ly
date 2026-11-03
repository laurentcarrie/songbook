\version "2.24.0"

%% Number of 4/4 bars covered by the beat marks and the MIDI drums.
nbbars = 4

\header {
  title = "riff couplet"
  instrument = "guitar"
  tagline = ##f
}

\include "defs.ly"

harmonies = \chordmode { d1:m d1:m c1 c1 }

melody = {
  \time 4/4
  \songTempo

  c16\6 (d16\6) d'16\4 d'16\4 
  d8\6 d'16\4 d'16\4 
  c16\6 (d16\6) d'16\4 d'16\4 
  d8\6 d'16\4 d'16\4 
   |
  c16\6 (d16\6) d'16\4 d'16\4 
  d8\6 d'16\4 d'16\4 
  d8\6 f'16\3 f'16\3 
  d8\6 f'16\3 f'16\3 
   |
  bes,16\6(c16\6) c'16\4 c'16\4 
  c8\6 c'16\4 c'16\4 
  bes,16\6(c16\6) c'16\4 c'16\4 
  c8\6 c'16\4 c'16\4 
  |
  bes,16\6(c16\6) c'16\4 c'16\4 
  c8\6 c'16\4 c'16\4 
  bes,8\6 bes16\4 bes16\4 
  a,8\6 a16\4 a16\4 
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
    \new Dynamics { \songbookBeatMarks \nbbars }
    \new Dynamics { \songbookBeatShade \nbbars }
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
    } { \songbookDrums \nbbars }
  >>
  \midi {}
}
