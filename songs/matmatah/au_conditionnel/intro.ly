\version "2.20.0"

% Bb
ma = {

}

song_chords = \chordmode { c2 g:sus4 f e }



rhythm = {

}

lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0

    % mes 1
    < d\4 g\3  >8
    r8
    < f\4 bes\3  >8
    r8
    < g\4 c'\3  >4
    r8
    < d\4 g\3  >8
    |
    % mes 2
    r8
    < f\4 bes\3  >8
    r8
    < gis\4 cis'\3 >8
    < g\4 c'\3  >4
    r4
    |
    % mes 3
    < d\4 g\3 >8
    r8
    < f\4 bes\3  >8
    r8
    < g\4 c'\3  >4
    r8
    < f\4 bes\3  >8
    |
    % mes 4
    r8
    < d\4 g\3  >2
    r8
    r4
  }
}

drumbar =  \drummode {  bd4 sn4  bd4 sn4 }

drumbars = {
  \drumbar |   \drumbar |  \drumbar |  \drumbar |

}


drumbarhh =  \drummode {
  hihat8
  hihat8
  hihat8
  hihat8
  hihat8
  hihat8
  hihat8
  hihat8
}

drumbarshh = {
  \drumbarhh |  \drumbarhh |  \drumbarhh |  \drumbarhh |

}


\score {
  \unfoldRepeats {
    <<
      \new Staff {
        \clef "treble_8"
        \lead
        \set Staff.midiMinimumVolume = #0.9
        \set Staff.midiMaximumVolume = #0.9
        \set Staff.midiInstrument = "electric guitar (clean)"
      }
    >>
  }
  \layout{}
  %     \midi {
  %         \tempo 4 = \songtempo
  % }
}
