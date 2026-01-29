\version "2.23.1"
\include "macros.ly"


song_chords = \chordmode {
  g1:7 | c1:m7 | f1:m7 | aes:dim |
}


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1
    \repeat volta 3 {
      \bar ".|:"

      |
      % mesure 1
      <g\4 d'\3 f'\2 b'\1>8
      <g\4 d'\3 f'\2 b'\1>8

      <\deadNote g\4 \deadNote d'\3 \deadNote f'\2 \deadNote b'\1>16
      <g\4 d'\3 f'\2 b'\1>16
      r8

      <g\4 d'\3 f'\2 b'\1>8
      r8

      r4

      |
      % mesure 2
      <bes\4 ees'\3 g'\2 c''\1>8
      <bes\4 ees'\3 g'\2 c''\1>8

      <\deadNote bes\4 \deadNote ees'\3 \deadNote g'\2 \deadNote c''\1>16
      <bes\4 ees'\3 g'\2 c''\1>16
      r8

      <bes\4 ees'\3 g'\2 c''\1>8
      r8

      r4

      |
      %  mesure 3
      <  c'\4 ees'\3 aes'\2 c''\1>8
      <  c'\4 ees'\3 aes'\2 c''\1>8

      < \deadNote c'\4 \deadNote ees'\3 \deadNote aes'\2 \deadNote c''\1>16
      <  c'\4 ees'\3 aes'\2 c''\1>16
      r8

      <  c'\4 ees'\3 aes'\2 c''\1>8
      r8

      r4
      |

      % mesure 4
      <aes\4 d'\3 f'\2 b'\1>8
      <aes\4 d'\3 f'\2 b'\1>8

      <\deadNote aes\4 \deadNote d'\3 \deadNote f'\2 \deadNote b'\1>16
      <aes\4 d'\3 f'\2 b'\1>16
      r8

      <aes\4 d'\3 f'\2 b'\1>8
      r8

      r4

      |

    }
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
    \new ChordNames {
      \song_chords
    }

    \new TabStaff {
      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
    }

  >>

  \layout {}
}
