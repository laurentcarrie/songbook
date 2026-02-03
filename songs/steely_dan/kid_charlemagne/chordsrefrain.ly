\include "macros.ly"
%\xfafadfainclude "predefined-guitar-fretboards.ly"

<<
  \new ChordNames {
    \chordmode { f1 g1 f1:7 f1:7 g1:7 }
  }

  \new FretBoards {
    < a\4 c'\3 f'\2 a'\1>1
    < b\4 d'\3 g'\2 b'\1>1
    < c'\4 ees'\3 a'\2>1
    < f\5 a\4 ees'\3>1
    < g\5 b\4 f'\3>1
  }


  \new ChordNames {
    \chordmode { c1:7 }
  }
  \new FretBoards {
    < c'\4 e'\3 bes'\2>1
  }
>>
