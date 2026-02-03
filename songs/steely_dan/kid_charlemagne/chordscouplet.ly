\include "macros.ly"
\include "predefined-guitar-fretboards.ly"

<<
  \new ChordNames {
    \chordmode { a1:m7 g1:6 f1:6.9 bes1:9.13}
  }

  \new FretBoards {
    < e\5 g\4 c'\3 e'\2 a'\1>1
    < g,\6 g\4 b\3 e'\2 g'\1>1
    < f\5 a\4 d'\3 g'\2 c''\1>1
    < bes,\6 aes\4 d'\3 g'\2 c''\1 >1
  }
>>
