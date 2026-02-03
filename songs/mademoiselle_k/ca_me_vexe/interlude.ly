\version "2.23.1"

\include "macros.ly"

song_chords = \chordmode {

  | e1:m
  | g1
  | a1:m7
  | c1
  | e1:m
  | g1
  | a1:m7
  | c1

}



lead = {
  \absolute  {

    \repeat percent 2 {

      | r8 e'8\3 fis'8\2 g'8\2 a'8\2 g'8\2 fis'8\2 g'8\2
      | e'4\3 r8 e'4\3  r8 e'4\3
      | r8 e'8\3 fis'8\2 g'8\2 a'8\2 g'8\2 fis'8\2 g'8\2
      %| \grace a'4\2 \bendhold \^ ais'\2 r4 r2

      <>^\markup \typewriter "'hold"
      \grace a'4.\2\^ ais'\bendHold \^ g'4.\2 fis'4\2

      |

    }

  }


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
       ("100" . "hundred")
       ("dpi" . "dots per inch")
       ))

}


\score {
  <<

    %    \new FretBoards {
    %    <c\5 g\4 c'\3 ees'\2 g'\1>1
    %    <ees\5 bes\4 ees'\3 ges'\2 bes'\1>1
    %    <aes,\6 ees\5 aes\4 c'\3 ees'\2 aes'\1 >1
    %    %<b,\6 fis\5 a\4 d'\3 fis'\2 b'\1>1
    %    %<c\6_\thumb c'\4 e'\3 g'\2 b'\1>1
    %  }

    \set Score.currentBarNumber = 89

    \new ChordNames {
      \song_chords
    }


    \new TabStaff {
      \tempo 4 = 72
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
    }

  >>

  \layout {}

}



\score {

  \lead

  \midi {
    \tempo 4 = 72
  }
}
