\version "2.24.0"

\header {
  title = "couplet"
  instrument = "guitare"
  tagline = ##f
}

\include "../../songbook.ily"

#(if (file-exists? "macros.ly")
     (ly:parser-include-string "\\include \"macros.ly\"")
     (ly:parser-define! 'songtempo 83))

songTempo = { \tempo 4 = \songtempo }

harmonies = \chordmode { 
  \repeat percent 2 {
  e1 e1 cis1:m cis1:m
  } 
  a:1 a:1 b:1 b:1
  }

melody = {
  \clef "treble_8"
  \time 4/4
  \songTempo

  \repeat percent 2 {
  e'16\2 fis'8\2 gis'16\1 ~
  gis'16\1 dis'8\2 e'16\2 ~
  e'16\2 fis'8\2 gis'16\1 ~
  gis'16\1 
  dis'8\2 e'16\2 ~
  
    |
  e'16\2 fis'8\2 gis'16\1 ~
  gis'16\1 dis'8\2 e'16\2 ~
  e'16\2 fis'8\2 gis'16\1 ~
  gis'16\1 
  dis'8.\2
    |
  % C#m
  cis'16\3 dis'8\2 e'16\2 ~
  e'16\2 b8\3 cis'16\3 ~
  cis'16\3 dis'8\2 e'16\2 ~
  e'16\2 b8\3 cis'16\3 ~
  |
  cis'16\3 dis'8\2 e'16\2 ~
  e'16\2 b8\3 cis'16\3 ~
  cis'16\3 dis'8\2 e'16\2 ~
  e'16\2 b8.\3

  }
  | 

  % A
  cis'16\3 dis'8\2 e'16\2 ~
  e'16\2 b8\3 cis'16\3 ~
  cis'16\3 dis'8\2 e'16\2 ~
  e'16\2 b8\3 cis'16\3 ~
  |
  cis'16\3 dis'8\2 e'16\2 ~
  e'16\2 b8\3 cis'16\3 ~
  cis'16\3 dis'8\2 e'16\2 ~
  e'16\2 b8.\3
  |
  % B
  b16\3 cis'8\2 dis'16\2 ~
  dis'8\2 b8\3 
  b16\3 cis'8\2 dis'16\2 ~
  dis'8\2 b8\3
  |
  % B
  b16\3 cis'8\2 dis'16\2 ~
  dis'8\2 b8\3 
  b16\3 cis'8\2 dis'16\2 ~
  dis'8\2 b8\3
  

}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \tabDurations \melody }
    \new Dynamics { \songbookBeatMarks 12 }
  >>
  \layout {}
}

\score {
  \unfoldRepeats <<
    \new TabStaff \melody
    %% MIDI balance, \midi score only. Default velocity is 90/127.
    \new DrumStaff \with {
      midiMinimumVolume = #0.9
      midiMaximumVolume = #1.0
    } { \songbookDrums 12 }
  >>
  \midi {}
}
