\version "2.24.0"

%% Shared definitions for pont.ly and pont-rythmique.ly.
%% Definitions ONLY - no \header and no \score. A file with a \score cannot be
%% included: its scores would be emitted again in the including file, adding
%% pages to the PDF and a second <name>-1.midi that the build does not expect.
%% Bold glissando. Thickness only - the line keeps its natural length, so
%% between adjacent frets it stays short.
boldGlissando = {
  \override Glissando.thickness = #5
}

%% Show note durations in the tablature. A TabStaff hides stems, flags, beams
%% and dots by default; this is the rhythm-related subset of \tabFullNotation,
%% without the time signature, dynamics and tuplet brackets it also restores.
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

accord_cm =
#(define-music-function (dur) (ly:duration?)
   #{ <c\5 g\4 c'\3 dis'\2>$dur #})

mesure_cm = {
  |
  \accord_cm 16 q16  r16   \accord_cm 16 
  q16 q16 r16 \accord_cm 16 
  q16 q16 r16 \accord_cm 16 
  q16 r16 \accord_cm 16 r16
  |
}

accord_g =
#(define-music-function (dur) (ly:duration?)
   #{ <g,\6 c\5 g\4 b\3 d'\2>$dur #})

mesure_g = {
  \accord_g 16 q16   r16   \accord_g 16 
  \accord_g 16 \accord_g 16 r16 \accord_g 16 
  q16 q16 r16 \accord_g 16 
  q16 r16 \accord_g 16 r16
}

accord_b =
#(define-music-function (dur) (ly:duration?)
   #{ <b,\5 fis\4 b\3 dis'\2>$dur #})

mesure_b = {
  \accord_b 16 q16   r16   \accord_b 16 
  \accord_b 16 \accord_b 16 r16 \accord_b 16 
  q16 q16 r16 \accord_b 16 
  q16 r16 \accord_b 16 r16
}

accord_d =
#(define-music-function (dur) (ly:duration?)
   #{ <d\4 a\3 d'\2>$dur #})

mesure_d = {
  \accord_d 16 q16   r16   \accord_d 16 
  \accord_d 16 \accord_d 16 r16 \accord_d 16 
  q16 q16 r16 \accord_d 16 
  q16 r16 \accord_d 16 r16
}




%% Chord grid of the bridge: one name per bar, 8 bars. Shared by the melody
%% and the rhythm scores so the two can never drift apart.
harmonies = \chordmode { c1:m g1 b1 g1 c1:m g1 b1 d1 }

rythm = {
  \clef "treble_8"
  \mesure_cm
  |
  \mesure_g
  |
  \mesure_b
  |
  \mesure_g
  |
  \mesure_cm
  |
  \mesure_g
  |
  \mesure_b
  |
  \mesure_d

    
}
