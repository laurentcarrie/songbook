\include "macros.ly"
\include "predefined-guitar-fretboards.ly"

<<
  \new ChordNames {
    \chordmode { f1:m7 ees1:maj7 f1:dim c1:m7  }
  }

  \new FretBoards {
    <f\5 c'\4 ees'\3 aes'\2 >1
    <e\5 b\4 dis'\3 gis'\2  >1
    <b,\5 f\4 aes\3 d'\2 >1
    <c\5 g\4 bes\3 ees'\2>1
  }
>>
