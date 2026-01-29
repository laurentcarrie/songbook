\version "2.23.1"
\include "macros.ly"



song_chords = \chordmode {
  a1:m e1 f2 g2 a1:m |
  a1:m e1 f2 g2 a1:m
}

basse = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1

    a,,4\3 a,4\1 a,,4\3 a,4\1  |  e,,4\4 e,4\2 e,,4\4 e,4\2  |  f,,4\4 f,,4\4 g,,4\4 g,,4\4 | a,,4\3 a,4\1 a,,4\3 a,4\1  |
    a,,4\3 a,4\1 a,,4\3 a,4\1  |  e,,4\4 e,4\2 e,,4\4 e,4\2  |  f,,4\4 f,,4\4 g,,4\4 g,,4\4 | a,,4\3 a,4\1 a,,4\3 a,4\1  |

  }
}


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1

    c'4\3\staccato b4\3\staccato a4\3\staccato b4\3~|
    b4\3\staccato~ e'4\2\staccato~ dis'4\2\staccato~ e'4\2\staccato~ |
    g'4\1 f'4\2 dis'4\2 e'4\2 |
    a4\3 c'4\3 b4\3 a4\3~  |
    a4\3 e'4\2\staccato r4 e'4\2\staccato |
    r4 e'4\2\staccato dis'4\2\staccato e'4\2\staccato |
    g'4\1 f'4\2 dis'4\2 e'4\2 |
    c'4\3 e'4\2 b4\3 e'4\2 |
  }
}

drumbar =  \drummode {  bd4 bd4  bd4 bd4 }
drumbars = {
  \repeat unfold 8 { \drumbar | }
}

drumbarsn =  \drummode {
  r8 r8  sn16 sn16 sn16 r16  r8 r8  sn16 sn16 sn16 r16  |

}
drumbarsn = {
  \repeat unfold 8 { \drumbarsn | }
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
  \repeat unfold 8 {  \drumbarhh }

}




\paper {
  #(include-special-characters)
  indent = 0\mm
  line-width = 180\mm
  oddHeaderMarkup = ""
  evenHeaderMarkup = ""
  oddFooterMarkup = ""
  evenFooterMarkup = ""

  #(add-text-replacements!
    '(
       ("dpi" . "dots per inch")
       ))

}


\score {
  <<
    \new ChordNames {
      \song_chords
    }

    \new TabStaff {
      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
    }

    %    \new TabStaff {
    %      \tempo 4 = \songtempo
    %      \set Staff.stringTunings = #bass-tuning
    %      \tabFullNotation
    %      \override Score.BarNumber.break-visibility = ##(#t #t #t)
    %      %\clef bass
    %      \basse
    %    }
    %

  >>

  \layout {}
}


\score {
  <<
    %    \new ChordNames {
    %      \song_chords
    %    }

    \new TabStaff {
      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
    }

    \new TabStaff {
      \tempo 4 = \songtempo
      \set Staff.stringTunings = #bass-tuning
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      %\clef bass
      \basse
    }

    \new DrumStaff {
      \tempo 4 = \songtempo
      <<
        %\new DrumVoice {  \drumbarshh }
        \new DrumVoice {  \drumbars }
        \new DrumVoice { \drumbarsn }
      >>
    }


  >>

  \midi {
    \tempo 4 = \songtempo
  }
}
