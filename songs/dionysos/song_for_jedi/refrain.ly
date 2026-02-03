\include "macros.ly"
\storePredefinedDiagram
#default-fret-table
\chordmode { gis:m }
#guitar-tuning
% "The diagram definition can be either a fret-diagram-terse
% definition string..."
#"4;6;6;4;4;x;"
% "...or a fret-diagram-verbose marking list."
%   #'(
%    (mute 6)
%    (place-fret 5 3)
%    (place-fret 4 2)
%    (open 3)
%    (place-fret 2 1)
%    (open 1)
%   )

\storePredefinedDiagram
#default-fret-table
\chordmode { b }
#guitar-tuning
% "The diagram definition can be either a fret-diagram-terse
% definition string..."
#"x;2;4;4;4;x;"
% "...or a fret-diagram-verbose marking list."
%   #'(
%    (mute 6)
%    (place-fret 5 3)
%    (place-fret 4 2)
%    (open 3)
%    (place-fret 2 1)
%    (open 1)
%   )

\storePredefinedDiagram
#default-fret-table
\chordmode { b:sus4 }
#guitar-tuning
% "The diagram definition can be either a fret-diagram-terse
% definition string..."
#"x;2;4;4;5;x;"
% "...or a fret-diagram-verbose marking list."
%   #'(
%    (mute 6)
%    (place-fret 5 3)
%    (place-fret 4 2)
%    (open 3)
%    (place-fret 2 1)
%    (open 1)
%   )


\storePredefinedDiagram
#default-fret-table
\chordmode { e }
#guitar-tuning
% Again, "either a fret-diagram-terse definition string..."
#"x;7;6;4;5;x;"
% "...or a fret-diagram-verbose marking list."
% #'(
%   (mute 6)
%   (mute 5)
%   (open 4)
%   (place-fret 3 2)
%   (place-fret 2 3)
%   (place-fret 1 1)
% )

\storePredefinedDiagram
#default-fret-table
\chordmode { gis }
#guitar-tuning
% "The diagram definition can be either a fret-diagram-terse
% definition string..."
#"4;6;6;5;4;x;"
% "...or a fret-diagram-verbose marking list."
%   #'(
%    (mute 6)
%    (place-fret 5 3)
%    (place-fret 4 2)
%    (open 3)
%    (place-fret 2 1)
%    (open 1)
%   )

myChords = \chordmode {
  gis:m b b:sus4 e gis
}

<<
  \new ChordNames {
    \myChords
  }
  \new FretBoards {
    \myChords
  }
>>
