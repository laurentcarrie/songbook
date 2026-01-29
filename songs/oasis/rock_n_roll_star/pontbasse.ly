\version "2.24.4"
\include "macros.ly"


myChords = \chordmode {
  \repeat percent 3 { gis1:m   e1   b1   b1 }
  a1 a1 fis1:m fis1:m
}

lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \repeat percent 3 {
      gis,,4\4 gis,,4\4 gis,,8\4 gis,,8\4 gis,,8\4 e,,8\4~ |
      e,,4\4 e,,4\4 e,,8\4 e,,8\4 e,,8\4 b,,8\3~ |
      b,,4\3 b,,4\3 b,,8\3 b,,8\3 b,,8\3 b,,8\3~ |
      b,,4\3 b,,4\3 b,,8\3 b,,8\3 b,,8\3 b,,8\3 |
    }

    a,,4\4 a,,4\4 a,,8\4 a,,8\4 a,,8\4 a,,8\4~ |
    a,,4\4 a,,4\4 a,,8\4 a,,8\4 a,,8\4 a,,8\4~ |
    fis,,4\4 fis,,4\4 fis,,8\4 fis,,8\4 fis,,8\4 fis,,8\4~ |
    fis,,4\4 fis,,4\4 fis,,8\4 fis,,8\4 fis,,8\4 fis,,8\4 |


    r1
  }

}

drumbar =  \drummode {  bd4 sn4  bd4 sn4 }

drumbars = {
  \repeat unfold 15 { \drumbar | }
}


drumbarhh =  \drummode {
  sn8
  r8
  sn8
  r8
  sn8
  r8
  sn8
  r8
}

drumbarshh = {
  \repeat unfold 15 {  \drumbarhh }

}


\score {
  <<
    \new ChordNames \myChords
    \new TabStaff {
      \set Staff.stringTunings = #bass-tuning

      \clef bass

      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
      % \transpose g f { \lead }
      %\repeat percent 3 {\lead}
    }

  >>

  \layout {}
}


\score {
  \unfoldRepeats {
    <<
      \new DrumStaff
      \tempo 4 = \songtempo
      <<
        %\new DrumVoice {  \drumbarshh }
        \new DrumVoice {  \drumbars }
      >>

      \new Staff {
        \repeat unfold 3 {\lead}
        \set Staff.midiMinimumVolume = #0.9
        \set Staff.midiMaximumVolume = #0.9
        \set Staff.midiInstrument = "electric guitar (clean)"
      }
    >>
  }
  \midi {
    \tempo 4 = \songtempo
  }
}
