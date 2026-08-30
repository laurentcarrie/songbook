\version "2.24.0"

\header {
  title = "riff 2 (refrain)"
  instrument = "guitare"
  tagline = ##f
}

\include "defs-riff2.ly"


melody = {
  \clef "treble_8"
  \time 4/4
  \songTempo

  \repeat volta 2 {

    \repeat unfold 2 {
      e'8\3 a'8\2 b'8\1 cis''8\1~ 
      cis''8\1 cis''8\1 b'8\1 a'8\2 |
    }

    \repeat unfold 2 {
      fis'8\2 a'8\2 b'8\1 cis''8\1~ 
      cis''8\1 cis''8\1 b'8\1 a'8\2 |
    }
  }


}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \boldGlissando \tabDurations \melody }
    \new Dynamics { \songbookBeatMarks 4 }
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
