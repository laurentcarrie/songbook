\version "2.20.0"


\new ChordGrid \with {
  \override ChordSquare.measure-division-lines-alist =
  #'(((1) . ())
     ((1/3 1/3 1/3) . ((-1 -0.4 0 1) (0 -1 1 0.4))))
  \override ChordSquare.measure-division-chord-placement-alist =
  #'(((1) . ((0 . 0)))
     ((1/3 1/3 1/3) . ((-0.7 . 0.5) (0 . 0) (0.7 . -0.5))))
}
\chordmode {
  e1 | e1 |
}
