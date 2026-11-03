\version "2.24.0"

%% Number of 4/4 bars of the melody: used by the beat marks and the MIDI drums.
nbbars = 8

\header {
  title = "riff1"
  instrument = "guitare rythmique"
  tagline = ##f
}

\include "defs.ly"

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \boldGlissando \tabDurations \rythm }
    \new Dynamics { \songbookBeatMarks \nbbars }
    \new Dynamics { \songbookBeatShade \nbbars }
    % \new DrumStaff { \songbookDrums \nbbarsUnrolled }
  >>
  \layout {}
}

%% Number of 4/4 bars once the repeats are unrolled: that is what the MIDI plays,
%% so the drums must cover it (nbbars is the written length, for the beat marks).
#(define (bars-of name)
   (ly:moment-main (ly:music-length (unfold-repeats-fully (ly:parser-lookup name)))))
nbbarsUnrolled = #(inexact->exact (ceiling (max (bars-of 'rythm))))

\score {
  \unfoldRepeats <<
    \new TabStaff \rythm
    %% Louder than the guitar: raises the drum note-on velocity from 90 to 123
    %% out of 127. Only meaningful in the \midi score - it does nothing to the
    %% engraving. Lower midiMinimumVolume to soften it.
    \new DrumStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } { \songbookDrums \nbbars }
  >>
  \midi {}
}

