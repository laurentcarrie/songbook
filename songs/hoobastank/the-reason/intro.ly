\version "2.24.0"

%% Number of 4/4 bars covered by the beat marks and the MIDI drums.
nbbars = 4

\header {
  title = "intro"
  instrument = "guitare"
  tagline = ##f
}

\include "../../songbook.ily"

#(if (file-exists? "macros.ly")
     (ly:parser-include-string "\\include \"macros.ly\"")
     (ly:parser-define! 'songtempo 83))

songTempo = { \tempo 4 = \songtempo }

harmonies = \chordmode { e1 e1 e1 e1 }

melody = {
  \clef "treble_8"
  \time 4/4
  \songTempo

  \repeat percent 3 {
    e'16\2 fis'8\2 gis'16\1 ~
    gis'16\1 dis'8\2 e'16\2 ~
    e'16\2 fis'8\2 gis'16\1 ~
    gis'16\1
    dis'8\2 e'16\2 ~
  }
  |
  e'16\2 fis'8\2 gis'16\1 ~
  gis'16\1 dis'8\2 e'16\2 ~
  e'16\2 fis'8\2 gis'16\1 ~
  gis'16\1
  dis'8.\2
  |

}

\score {
  <<
    \new ChordNames \harmonies
    \new TabStaff { \tabDurations \melody }
    \new Dynamics { \songbookBeatMarks \nbbars }
    \new Dynamics { \songbookBeatShade \nbbars }
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
    } { \songbookDrums \nbbars }
  >>
  \midi {}
}
