\include "macros.ly"
\version "2.20.0"


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0

    % bar 1
    e16\5 e16\5 d'8\3
    e'8\3 e16\5 e16\5
    e16\5 d'16\3 \deadNote d'16\3 e'16\3~
    e'16\3 e16\5 e16\5 e16\5
    |
    % bar 2
    d8\4 d'8\3
    e'8\3 d16\4 d16\4
    d16\4 d'16\3 \deadNote d'16\3 e'16\3~
    e'16\3 < a,\5 \deadNote d\4 e'\3 >16 d16\4 d16\4
    |
    % bar 3
    b,8\6 <b,\6 \deadNote e\5 \deadNote a\4 d'\3>8
    e'8\3 b,16\6 b,16\6
    b,16\6 <b,\6 \deadNote e\5 \deadNote a\4 d'\3>16 <\deadNote b,\6 \deadNote e\5 \deadNote a\4 \deadNote e'\3>16  e'16\3~
    e'16\3 <b,\6 \deadNote a\5 \deadNote d\4 e'\3>16 b,16\6 b,16\6
    |
    % bar 4
    c8\6 <c\6 \deadNote e\5 \deadNote a\4 d'\3>8
    e'8\3 c16\6 c16\6
    c16\6 <c\6 \deadNote e\5 \deadNote a\4 d'\3>16 <\deadNote b,\6 \deadNote e\5 \deadNote a\4 \deadNote e'\3>16  e'16\3~
    e'16\3 <c\6 \deadNote a\5 \deadNote d\4 e'\3>16 c8\6

  }

}

drumbar =  \drummode {  bd4 sn4  bd4 sn4 }

drumbars = {
  \repeat unfold 8 { \drumbar | }
}


drumbarhh =  \drummode {
  sn8
  sn8
  sn8
  sn8
  sn8
  sn8
  sn8
  sn8
}

drumbarshh = {
  \repeat unfold 8 {  \drumbarhh }

}





\score {
  <<
    \new TabStaff {
      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
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
        \new DrumVoice {  \drumbarshh }
        \new DrumVoice {  \drumbars }
      >>

      \new Staff {
        \lead
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
