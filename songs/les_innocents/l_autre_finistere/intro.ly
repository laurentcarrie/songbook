\version "2.24.0"

\header {
  title = "intro"
  instrument = "Guitar"
  tagline = ##f
}


%% Show note durations in the tablature. A TabStaff hides stems, flags, beams
%% and dots by default; this is the rhythm-related subset of \tabFullNotation,
%% without the time signature, dynamics and tuplet brackets it also restores.
%% Bold glissando. Thickness only - the line keeps its natural length, so
%% between adjacent frets it stays short.
boldGlissando = {
  \override Glissando.thickness = #5
}

tabDurations = {
  \revert TabStaff.Stem.length
  \revert TabStaff.Stem.no-stem-extend
  \revert TabStaff.Stem.details
  \revert TabStaff.Stem.stencil
  \revert TabStaff.Flag.style
  \revert TabStaff.Flag.stencil
  \override TabStaff.Stem.stencil = #tabvoice::draw-double-stem-for-half-notes
  \override TabStaff.Stem.X-extent = #tabvoice::make-double-stem-width-for-half-notes
  \revert TabStaff.NoteColumn.ignore-collision
  \set TabStaff.autoBeaming = ##t
  \revert TabStaff.Beam.stencil
  \revert TabStaff.Dots.stencil
  \revert TabStaff.Tie.stencil
  \revert TabStaff.Tie.after-line-breaking
  %% A TabStaff also hides rests (engraver-init.ly sets Rest.stencil = ##f),
  %% so an r8 would simply be invisible.
  \revert TabStaff.Rest.stencil
  \revert TabStaff.MultiMeasureRest.stencil
  \revert TabStaff.MultiMeasureRestNumber.stencil
  \revert TabStaff.MultiMeasureRestText.stencil
}

melody = {
  \clef "treble_8"
  \time 4/4
  \tempo 4 = 120

  \repeat percent 3 {
    %% bar 1
    g,4  g4\4  g,8 f8~ f8  g,8 |
    %% bar 2
    e4 g,8 d8 ~ d8 g,8 bes,8  \glissando b,8 |
  }

  %% bar 7
  f,4 f4\4 f,8 ees8\4 ~ ees8\4 f,8\6 |
  %% bar 8
  d4\4 f,8 c8 ~ c8 f,8 bes,8 \glissando b,8 |



}

\score {
  <<
    % \new Staff \melody
    \new TabStaff { \boldGlissando \tabDurations \melody }
  >>
  \layout {}
}

%% Separate score for the MIDI: \repeat volta is only drawn as repeat barlines,
%% it is not played back. \unfoldRepeats expands it, so the MIDI matches what
%% the score means. Keep it out of the \layout score, or the repeat would be
%% printed written out.
\score {
  \unfoldRepeats <<
    \new Staff \melody
    \new TabStaff \melody
  >>
  \midi {}
}
