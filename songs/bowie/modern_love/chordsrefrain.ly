\include "macros.ly"
\include "predefined-guitar-fretboards.ly"

<<
  \new ChordNames {
    \chordmode { e2:m9 e2:m c2 c2:6 d2 d2:aug e2:m9 e2:m }
  }

  \new FretBoards {
    <e,\6 b,\5 e\4 g\3 b\2 fis'\1>2
    <e,\6 b,\5 e\4 g\3 b\2 g'\1>2

    <c\6 c'\4 e'\3 fis'\2>2
    <c\6 c'\4 e'\3 g'\2>2

    <d\5 a\4 d'\3 fis'\2>2
    <d\5 a\4 d'\3 g'\2>2

    <e,\6 b,\5 e\4 g\3 b\2 fis'\1>2
    <e,\6 b,\5 e\4 g\3 b\2 g'\1>2

  }
>>
