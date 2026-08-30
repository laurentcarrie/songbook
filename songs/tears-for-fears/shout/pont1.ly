\version "2.24.0"

\header {
  title = "pont 1"
  instrument = "guitare"
  tagline = ##f
}

\include "defs-pont1.ly"

melody = {
  \clef "treble_8"
  \time 4/4
  \songTempo

  \repeat volta 2 {

  fis,8\6 r8
  r8 r16 cis16\5
  e16\4 cis16\5 fis\4 r16
  fis,8\6 r8

  |

  r16 fis,16\6 b,16\5 cis16\5 e16\4 r16 fis16\4
  r8 cis16\5 e16\4 cis16\5 e16\4 fis16\4 fis,16\6 r16
  |

  fis16\4 r4 cis16\5 e16\4 cis16\5 fis16\4 r16
  r8 r8 r8 
  
  |
  
  fis,16\6 fis,16\6 fis,16\6  r8
  cis16\5 e16\4 cis16\5 fis16\4 fis,16\6 r8 
  fis,16\6 r8. 

  |
  }


  \repeat volta 2 {

  a8\3 r8
  r8 r16 fis16\4
  gis16\3 fis16\4 a\3 r16
  fis8\4 r8
 |
  r8. e16\4 fis16\4 gis16\3 r16 a16\3 r16
  fis16\4 gis16\3 fis16\4 gis16\3 a16\3 fis16\4 r16
  |
  a8\3 r8
  r8 r16 fis16\4
  gis16\3 fis16\4 a\3 r16
  r4
 |
 
  fis16\4 fis16\4 fis16\4  r4 
  fis16\4 gis16\3 fis16\4 a16\3 
  fis16\4 r4

  |
  }


}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \boldGlissando \tabDurations \melody }
    \new Dynamics { \songbookBeatMarks 8 }
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
    % \new TabStaff \with {
    %   midiMinimumVolume = #0.2
    %   midiMaximumVolume = #0.8
    % } \rythm
    \new DrumStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } { \songbookDrums 8 }
  >>
  \midi {}
}

% touch
