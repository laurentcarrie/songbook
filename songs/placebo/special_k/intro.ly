\version "2.20.0"
\include "macros.ly"
100

ma = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    <ais,\5 cis'\4 f'\3 c'\2 f'\1>8
    <ais,\5 cis'\4 f'\3 c'\2 f'\1>8

    <ais,\5 cis'\4 f'\3 c'\2 f'\1>16
    <ais,\5 cis'\4 f'\3 c'\2 f'\1>16
    <ais,\5 cis'\4 f'\3 c'\2 f'\1>16
    <ais,\5 c'\4   f'\3 c'\2 f'\1>16~

    <ais,\5 c'\4 f'\3 c'\2 f'\1>16
    <ais,\5 c'\4 f'\3 c'\2 f'\1>8
    <ais,\5 c'\4 f'\3 c'\2 f'\1>16~

    <ais,\5 c'\4 f'\3 c'\2 f'\1>16
    <ais,\5 c'\4 f'\3 c'\2 f'\1>16
    <ais,\5 c'\4 f'\3 c'\2 f'\1>16
    <ais,\5 c'\4 f'\3 c'\2 f'\1>16
  }
}

mb = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    <f,\6 f\5 gis\4>16
  }
}

lead = {
  \ma | \ma | \mb | \mb
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

cuatroTuning = #'(11 18 14 9)

\score {
  <<
    \new TabStaff {
      %\set TabStaff.stringTunings =  \stringTuning <e, a, d g b e'>

      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \repeat percent 8 {\lead}
    }

  >>

  % \layout {}
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
        \repeat unfold 8 {\lead}
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
