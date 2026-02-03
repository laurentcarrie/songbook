\include "macros.ly"
\version "2.20.0"
nb_mesures = 32
songtempo=94


song_chords = \chordmode {

  \repeat unfold 8 { r1 }

  e1 | e1 | e1 | e1 |
  c1 | c1 | a1 | a1 |


}


ma = {

  \repeat unfold 3 {< e\5 b\4 e'\3 g'\2>4}
  < e\5 b\4 e'\3 g'\2>8.
  < e\5 b\4 d'\3 fis'\2>16

}

mb = {
  \repeat unfold 2 {< e\5 b\4 d'\3 fis'\2>4}
  < e\5 b\4 d'\3 a'\2 > 8.
  < e\5 b\4 d'\3 a'\2 > 16
  < e\5 b\4 d'\3 a'\2 > 8.
  < e\5 a\4 d'\3 fis'\2 > 16



}


mc = {

  < e, b, e gis >4
  < e, b, e gis >4
  < e, b, e gis >4
  < e, b, e gis >4


}


md = {

  < a e >4
  < a e >4
  < a e >4
  < a e >4


}



rhythm = {
  \repeat percent 4 { \ma | \mb  }

  \repeat unfold 4 { \ma | \mb  }
}

% pour la basse
bm_E = { e,4 b,4 e,4 b,4 | }
bm_C = { c4 g4 c4 g4 | }
bm_A = { a,4 e4 a,4 e4 | }

lead_pattern = {
  \repeat unfold 4 { \bm_E | }
  \repeat unfold 2 { \bm_C | }
  \repeat unfold 2 { \bm_A | }
}

lead = {
  \override Score.SpacingSpanner.shortest-duration-space = #4.0
  \set Score.currentBarNumber = 0
  \repeat percent 8 { r1 | }
  \set Score.currentBarNumber = 1

  \lead_pattern |
  \lead_pattern |
  \lead_pattern |

}

song_voice = {
  \repeat unfold 15 { r1 } |
  r2. r8 a'8 |
  b'8 b'8 b'8 b'8 b'8 r8 r4 |


}

song_lyrics = \lyricmode {
  J'ai vendu ma misère pour une voix de soumission
  Au fond de moi la sentinelle pour y briller sans exception
  Et les sourires étaient les mêmes


  A-t-on le cri du coeur, la vérité ou la raison ?
  Vous n'entendez donc que la bête
  Et ses réponses à vos questions
}

drumbar =  \drummode {  bd4 sn4  bd4 sn4 }

drumbars = {
  \repeat percent 8 { r1 | }
  \repeat percent \nb_mesures { \drumbar }

}


drumbarhh =  \drummode {
  hihat8
  hihat8
  hihat8
  hihat8
  hihat8
  hihat8
  hihat8
  hihat8
}

drumbarshh = {
  \repeat percent 8 { r1 | }
  \repeat percent \nb_mesures { \drumbarhh }

}


\score {
  <<
    \new TabStaff {
      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
      %\repeat percent 3 {\lead}
    }

  >>

  \midi {}

  \layout {}
}
