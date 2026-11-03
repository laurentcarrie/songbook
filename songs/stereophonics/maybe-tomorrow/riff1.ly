\version "2.24.0"

%% Number of 4/4 bars of the melody: used by the beat marks and the MIDI drums.
nbbars = 1

\header {
  title = "riff1 (intro et pré-solo)"
  instrument = "mélodie"
  tagline = ##f
}

\include "defs.ly"


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
    \new Dynamics { \songbookBeatMarks \nbbars }
    \new Dynamics { \songbookBeatShade \nbbars }
    % \new TabStaff { \boldGlissando \tabDurations \rythm }
  >>
  \layout {}
}

%% Separate score for the MIDI: \repeat volta is only drawn as repeat barlines,
%% it is not played back. \unfoldRepeats expands it, so the MIDI matches what
%% the score means. Keep it out of the \layout score, or the repeat would be
%% printed written out.
%% Number of 4/4 bars once the repeats are unrolled: that is what the MIDI plays,
%% so the drums must cover it (nbbars is the written length, for the beat marks).
#(define (bars-of name)
   (ly:moment-main (ly:music-length (unfold-repeats-fully (ly:parser-lookup name)))))
nbbarsUnrolled = #(inexact->exact (ceiling (max (bars-of 'melody) (bars-of 'rythm))))

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
    } { \songbookDrums \nbbarsUnrolled }
  >>
  \midi {}
}

% touch
