\include "macros.ly"
\include "predefined-guitar-fretboards.ly"

<<
  \new ChordNames {
    \chordmode { c1:m bes1:m aes1 aes1 }
  }

  \new FretBoards {
    <c\5 g\4 c'\3 ees'\2 g'\1>1
    <ees\5 bes\4 ees'\3 ges'\2 bes'\1>1
    <aes,\6 ees\5 aes\4 c'\3 ees'\2 aes'\1 >1
    %<b,\6 fis\5 a\4 d'\3 fis'\2 b'\1>1
    %<c\6_\thumb c'\4 e'\3 g'\2 b'\1>1
  }
>>
