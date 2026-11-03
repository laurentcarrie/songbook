%% Shared LilyPond library for the whole song corpus.
%%
%% This copy is compiled into the band-songbook binary and written to
%% <sandbox>/songs/songbook.ily on every build, so a corpus that never wrote
%% one still gets the macros. A songbook.ily beside the corpus settings.yml
%% replaces it verbatim - that is the hook for adding your own.
%%
%% Songs reach it with a relative include, from the generated macros.ly:
%%
%%     \include "../../songbook.ily"
%%
%% Put your own copy in the corpus if you want that to resolve from
%% songs/<artist>/<song>/ as well as from the sandbox mirror: that is what
%% lets a .ly compile straight from songs/ in the editor.
%%
%% Only per-song values belong in the generated macros.ly - songtempo.

% Red tick on every beat, as a transcription guide. Takes the number of 4/4
% bars to cover - pass the bar count of the score it sits beside. Odd beats (1
% and 3) get a square, even beats (2 and 4) a cross, so the backbeat is legible
% at a glance. Put it in a Dynamics context next to the TabStaff: a plain second
% Voice inside a TabStaff is not a TabVoice and wrecks the tablature. Before the
% staff puts the marks above it, after it puts them below.
songbookBeatMarks =
#(define-music-function (bars) (integer?)
   #{
     \repeat unfold $bars {
       s4^\markup { \with-color #red \bold "▮" }
       s4^\markup { \with-color #red \bold "✖" }
       s4^\markup { \with-color #red \bold "▮" }
       s4^\markup { \with-color #red \bold "✖" }
     }
   #})

% Basic backbeat: bass drum on 1 and 3, snare on 2 and 4, hi-hat on every
% eighth. Takes the number of 4/4 bars. Two voices, because the hi-hat runs
% against the drum/snake pattern:
%
%     \new DrumStaff { \songbookDrums 8 }
%
% It is real drum music, so it plays in the MIDI (channel 10) as well as being
% engraved - unlike \songbookBeatMarks, which is a purely visual guide.
songbookDrums =
#(define-music-function (bars) (integer?)
   #{
     \drummode {
       \repeat unfold $bars {
         <<
           \new DrumVoice { \voiceOne hh8 hh hh hh hh hh hh hh }
           \new DrumVoice { \voiceTwo bd4 sn4 bd4 sn4 }
         >>
       }
     }
   #})

% A TabStaff hides articulations (staccato, accent...) by default, and the
% rhythm-only tab setups some songs use do not restore them. Show them on
% every tab staff, so c4-. or c4^. prints its dot.
\layout {
  \context {
    \TabStaff
    \revert Script.stencil
  }
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

%% PROTOTYPE - light grey background on beats 1 and 3, behind the staff.
%% Takes the number of 4/4 bars. Put it in its own Dynamics context next to the
%% TabStaff, like songbookBeatMarks. Each shaded beat is a TextSpanner from the
%% beat to the next one; its stencil is replaced by a filled box as tall as the
%% StaffSymbol found in the same system, so the box follows the real beat width.
#(define (beat-shade-stencil grob)
   (let* ((sys (ly:grob-system grob))
          (left (ly:spanner-bound grob LEFT))
          (right (ly:spanner-bound grob RIGHT))
          (me-x (ly:grob-relative-coordinate grob sys X))
          (me-y (ly:grob-relative-coordinate grob sys Y))
          ;; The box starts at the left edge of the notes in the column (not at
          ;; the column reference point), so it never reaches back over the
          ;; previous beat however tightly the notes are spaced.
          (edge (lambda (col)
                  (let ((ext (ly:grob-extent col col X)))
                    (+ (- (ly:grob-relative-coordinate col sys X) me-x)
                       (if (interval-empty? ext) 0 (car ext))))))
          (pad 0.3)
          (x0 (- (edge left) pad))
          (x1 (- (edge right) pad))
          (symbols (filter (lambda (g) (grob::has-interface g 'staff-symbol-interface))
                           (ly:grob-array->list (ly:grob-object sys 'all-elements)))))
     (if (null? symbols)
         empty-stencil
         (let* ((ss (car symbols))
                (ext (ly:grob-extent ss sys Y))
                (y0 (- (car ext) me-y))
                (y1 (- (cdr ext) me-y)))
           (stencil-with-color
            (ly:round-filled-box (cons x0 x1) (cons (- y0 0.5) (+ y1 0.5)) 0)
            (x11-color 'grey90))))))

songbookBeatShade =
#(define-music-function (bars) (integer?)
   #{
     \override TextSpanner.stencil = #beat-shade-stencil
     \override TextSpanner.X-extent = #'(0 . 0)
     \override TextSpanner.Y-extent = #'(0 . 0)
     \override TextSpanner.Y-offset = #0
     \override TextSpanner.outside-staff-priority = ##f
     \override TextSpanner.layer = #-5
     \repeat unfold $bars {
       s4\startTextSpan s4\stopTextSpan
       s4\startTextSpan s4\stopTextSpan
     }
   #})
