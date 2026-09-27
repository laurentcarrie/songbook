\version "2.24.3"

\include "macros.ly"
\include "predefined-guitar-fretboards.ly"

<<
  \new ChordNames {
    \chordmode {
      e1 fis1 gis1 cis:m
      ais:dim7 c:dim e
    }
  }

  \new FretBoards {
    <e,\6 b,\5 e\4 gis\3 >1
    <fis,\6 cis\5 fis\4 ais\3 >1
    <gis,\6 dis\5 gis c'\3>1
    <cis\5 gis\4 cis'\3 e'\2>1
    <ais,\6 g\4 cis'\3 e'\2>1
    <c\5 fis\4 c'\3 dis'\2>1
    <b,\5 e\4 b\3 e'\2>

  }

>>
