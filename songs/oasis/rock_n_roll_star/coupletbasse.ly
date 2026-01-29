\version "2.24.4"
\include "macros.ly"


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    b,,4\4 b,,4\4 a,,8\4 b,,8\4 a,,8\4 b,,8\4~ |
    b,,8\4 a,,8\4 b,,8\4 d,8\3 e,8\3 d,8\3 b,,8\4 a,,8\4 |
    b,,4\4 b,,4\4 a,,8\4 b,,8\4 a,,8\4 b,,8\4~ |
    b,,8\4 a,,8\4 b,,8\4 d,8\3 e,8\3 d,8\3 b,,8\4 a,,8\4 |
    cis,4\4 cis,4\4 cis,8\4 cis,8\4 cis,8\4 a,,8\4~|
    a,,4\4 a,,4\4 a,,8\4 a,,8\4 a,,4\4|
    b,,4\4 b,,4\4 a,,8\4 b,,8\4 a,,8\4 b,,8\4~ |
    b,,8\4 a,,8\4 b,,8\4 d,8\3 e,8\3 d,8\3 b,,8\4 a,,8\4 |
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
