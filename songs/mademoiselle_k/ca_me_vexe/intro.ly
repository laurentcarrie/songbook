\version "2.23.1"


song_chords = \chordmode {
  | e4:m   a4:7-11  e4:m  a4:m |
  | a1:m |
  | e4:m   a4:7-11  e4:m  a4:m |
  | a1:m
  | e4:m   a4:7-11  e4:m  a4:m |
  | a1:m
  | a2.:m7 a2:m11
}


lead = {
  \absolute  {

    |    <b,\5 g\3 b\2>4     <e\4 g\3 d'\2>4 <b,\5 g\3 b\2>4 <a,\5 e\4 a\3 c'\2>4
    |    <a,\5 e\4 a\3 c'\2>2 r2
    |    <b,\5 g\3 b\2>4     <e\4 g\3 d'\2>4 <b,\5 g\3 b\2>4 <a,\5 e\4 a\3 c'\2>4
    |    <a,\5 e\4 a\3 c'\2>2 r2
    |    <b,\5 g\3 b\2>4     <e\4 g\3 d'\2>4 <b,\5 g\3 b\2>4 <a,\5 e\4 a\3 c'\2>4
    |    <a,\5 e\4 a\3 c'\2>2 r2
    |    <e\4 g\3 c'\2 e'\1>4 <c'\2 g'\1>4 <c'\2 e'\1>4 <e\4 a\3 c'\2 fis'\1>4
    |    <e\4 a\3 c'\2 fis'\1>2~ r2


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
