\version "2.24.0"

%% Corpus-wide library: articulation marks, songbookBeatMarks. A real file
%% under songs/, mirrored into the sandbox, so this include resolves both when
%% the build compiles the sandbox copy and when the editor compiles the source.
\include "../../songbook.ily"

%% macros.ly carries only `songtempo = <song.yml info.tempo>`, the one value
%% that differs per song. band-songbook generates it next to the .ly, so it is
%% there during a build but NOT when this file is compiled straight from songs/
%% in the editor - and a missing \include is a hard error. Hence the guard:
%% \include cannot go inside an if, but ly:parser-include-string can.
%%
%% The fallback is editor-only. A build always finds macros.ly and therefore
%% always uses the real tempo from song.yml; 100 here is just something to
%% compile with, not the song's tempo.
#(if (file-exists? "macros.ly")
     (ly:parser-include-string "\\include \"macros.ly\"")
     (ly:parser-define! 'songtempo 100))

%% Shared definitions for couplet.ly and couplet-rythmique.ly.
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

accord_ebemol =
#(define-music-function (dur) (ly:duration?)
   #{ <ees\5 g\4 bes\3 dis'\2>$dur #})


accord_cm =
#(define-music-function (dur) (ly:duration?)
   #{ <c\5 g\4 c'\3 dis'\2>$dur #})


accord_gm =
#(define-music-function (dur) (ly:duration?)
   #{ <g,\6 d\5 g\4 bes\3 d'\2>$dur #})


accord_f =
#(define-music-function (dur) (ly:duration?)
   #{ <c\5 f\4 c'\3 f'\2>$dur #})


mesure_ebemol = {
  \accord_ebemol 8.
  \accord_ebemol 16
  \accord_ebemol 16
  r16
  \deadNote \accord_ebemol 16
  \accord_ebemol 16
  r16
  \accord_ebemol 16
  r16
  \accord_ebemol 16
  \accord_ebemol 4
}




mesure_cm = {
  \accord_cm 8.
  \accord_cm 16
  \accord_cm 16
  r16
  \deadNote \accord_cm 16
  \accord_cm 16
  r16
  \accord_cm 16
  r16
  \accord_cm 16
  \accord_cm 4
}



mesure_gm= {
  \accord_gm 8.
  \accord_gm 16
  \accord_gm 16
  r16
  \deadNote \accord_gm 16
  \accord_gm 16
  r16
  \accord_gm 16
  r16
  \accord_gm 16
  \accord_gm 4
}

mesure_f= {
  \accord_f 8.
  \accord_f 16
  \accord_f 16
  r16
  \deadNote \accord_f 16
  \accord_f 16
  r16
  \accord_f 16
  r16
  \accord_f 16
  \accord_f 16 
  \accord_f 16 
  \accord_f 16 
  \accord_f 16 
}

harmonies = \chordmode { ees1 c1:m g1:m f1 ees1 c1:m g1:m f1 }
songTempo = { \tempo 4 = \songtempo }

rythm = {
  \clef "treble_8"
  \songTempo

  \repeat percent 2 {

  \mesure_ebemol
  |
  \mesure_cm
  |
  \mesure_gm
  |
  \mesure_f
  |
  }   
}
