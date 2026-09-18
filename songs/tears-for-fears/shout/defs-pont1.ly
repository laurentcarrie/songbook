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

%% Shared definitions for riff1.ly and riff1-rythmique.ly.
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

accord_fis =
#(define-music-function (dur) (ly:duration?)
   #{ <fis,\6>$dur #})




mesure_fis = {
  \accord_fis 4
  \accord_fis 4
  \accord_fis 4
  \accord_fis 4

}


harmonies = \chordmode { fis:m }
songTempo = { \tempo 4 = \songtempo }

rythm = {
  \clef "treble_8"
  \songTempo

  \repeat volta 16 {
    \mesure_fis
    |
  }
}
