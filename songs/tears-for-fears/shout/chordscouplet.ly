\include "macros.ly"
\include "predefined-guitar-fretboards.ly"

<<
  \new ChordNames {
    \chordmode { fis1:m d1 b1:m fis1:m }
  }

  \new FretBoards {
    <fis,\6 cis\5 fis\4 a\3>1
    <a,\5 d\4 a\3 d'\2>1
    < b,\6 fis\5 b\4 d'\3 b\2>1
    <fis,\6 cis\5 fis\4 a\3>1
  }

>>
