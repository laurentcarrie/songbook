\version "2.23.1"


song_chords = \chordmode {

  | e1
  | e1
  | fis1
  | gis1:m


}



lead = {
  \absolute  {

  {

    e,8\6 fis8\4 e8\5 e,8\6     fis8\4 e8\5 e,8\6 e8\5
    |
    e,8\6 fis8\4 e8\5 e,8\6     fis8\4 e8\5 e,8\6 e8\5
    |
    fis,8\6 fis8\4 cis8\5 fis,8\6 fis8\4 cis8\5 fis,8\6 cis8\5
    |
    gis,8\6 gis8\4 dis8\5 gis,8\6 gis8\4 dis8\5 gis,8\6 dis8\5  
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
    \tempo 4 = 105
  }
}
