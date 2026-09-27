\version "2.24.0"

\header {
  title = "final"
  instrument = "guitare"
  tagline = ##f
}

\include "defs-pont1.ly"

harmonies = \chordmode {
  fis1:m
  fis1:m q q q d1 q b1:m q
  fis1:m q q q d1 q b1:m q
}



melody = {
  \clef "treble_8"
  \time 4/4
  \songTempo

  \absolute {

    | % bar 1
    r1
    | % bar 2-3
    \repeat percent 2 {
      e'16\2
      fis'16\2 ~ fis'16\2 fis'16\2 fis'16\2
      r16 fis'16\2 fis'16\2 e'16\2
      fis'16\2 ~ fis'16\2 fis'16\2 fis'16\2
      r16 fis'16\2 fis'16\2
    }
    | % bar 4
    e'8\3 fis'8\2
    b'8\1 cis''8\1~
    cis''4.\1 e'8\3 ~
    | % bar 5
    e'8\3 fis'8\2
    a'4\2
    e'8\3 fis'8\2 a'4\2
    | % bar 6
    % D
    % \textMark \markup { \italic "reprise du thème" }
    e''4.\1 ~
    e''16\1 d''16\1
    cis''4.\1 ~
    cis''16\1 b'16\2
    | % bar 7
    a'4.\2 ~
    a'16\2 fis'16\2
    e'2\3
    | % bar 8
    % Bm
    e'8\3 fis'8\2
    b'8\1 cis''8\1~
    cis''2\1
    | % bar 9
    e'8\3 fis'8\2
    b'8\1 cis''8\1~
    cis''4.\1
    a'16\2 b'16\2
    | % bar 10
    % Fsm
    b'16\2\^ cis''16\2 e''8\1
    b'16\2\^ cis''16\2 e''8\1
    b'16\2\^ cis''16\2 e''8\1
    b'16\2\^ cis''16\2 e''8\1
    | % bar 11
    b'16\2\^ cis''16\2 e''8\1
    b'16\2\^ cis''16\2 e''8\1
    b'16\2\^ cis''16\2\^ b'16\2
    a'16\2 a'4\2
    | % bar 12
    gis''8\1\^ a''8\1
    e''8\1 cis''8\2 ~
    cis''4\2
    r8
    a'8\3 ~
    | % bar 13
    a'8\3 b'8\2 cis''8\2 e''8\1
    a'8\3 b'8\2
    cis''8\2 d''8\2
    | % bar 14
    e''4.\1 ~
    e''16\1 d''16\1
    cis''4.\1 ~
    cis''16\1 b'16\2
    | % bar 15
    a'4.\2 ~
    a'16\2 fis'16\2
    e'2\3
    | % bar 16
    % Bm
    e'8\3 fis'8\2
    b'8\1 cis''8\1~
    cis''2\1
    | % bar 17
    % Bm
    e'8\3 fis'8\3
    b'8\2 cis''8\1
    b'8\2\^ cis''4\2
    | % bar 18
    % Fsm
    b'16\2\^ cis''16\2 e''8\1
    b'16\2\^ cis''16\2 e''8\1
    b'16\2\^ cis''16\2 e''8\1
    b'16\2\^ cis''16\2 e''8\1



  }
}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \boldGlissando \tabDurations \melody }
    \new Dynamics { \songbookBeatMarks 16 }
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
    } { \songbookDrums 3 }
  >>
  \midi {}
}

