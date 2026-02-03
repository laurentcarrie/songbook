\include "macros.ly"
\version "2.23.1"


song_chords = \chordmode {
  c2:m f2:m7 | bes2 ees2 |
  c2:m7 f2:7  | aes2 g2
}


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0

    \set Score.currentBarNumber = 1
    \repeat volta 3 {
      \bar ".|:"
      |
      % mesure 1
      < c'\4 ees'\3 g'\2 c''\1>8
      < c'\4 ees'\3 g'\2 c''\1>8

      < \deadNote c'\4 \deadNote ees'\3 \deadNote g'\2 \deadNote c''\1>16
      < c'\4 ees'\3 g'\2 c''\1>16
      r8

      < c'\4 ees'\3 g'\2 c''\1>8
      r8

      < c'\4 ees'\3 aes'\2 c''\1>16
      < c'\4 ees'\3 aes'\2 c''\1>16
      %< c'\4 ees'\3 aes'\2 c''\1>16
      < \deadNote c'\4 \deadNote ees'\3 \deadNote aes'\2 \deadNote c''\1>16
      < \deadNote c'\4 \deadNote ees'\3 \deadNote aes'\2 \deadNote c''\1>16


      |
      % mesure 2
      < bes\4 d'\3 f'\2 bes'\1>8
      < bes\4 d'\3 f'\2 bes'\1>8

      < \deadNote bes\4 \deadNote d'\3 \deadNote f'\2 \deadNote bes'\1>8
      < bes\4 d'\3 f'\2 bes'\1>8

      < \deadNote ees\5 \deadNote bes\4 \deadNote ees'\3 \deadNote g'\2 >16
      < \deadNote ees\5 \deadNote bes\4 \deadNote ees'\3 \deadNote g'\2 >16
      < ees\5 bes\4 ees'\3 g'\2 >8

      < ees\5 bes\4 ees'\3 g'\2 >16
      < ees\5 bes\4 ees'\3 g'\2 >16
      < \deadNote ees\5 \deadNote bes\4 \deadNote ees'\3 \deadNote g'\2 >16
      < \deadNote ees\5 \deadNote bes\4 \deadNote ees'\3 \deadNote g'\2 >16

      ^\markup { \bold "3×" }
    }

    |
    < c'\4 ees'\3 bes'\2 c''\1 >8
    < c'\4 ees'\3 bes'\2 c''\1 >8

    < \deadNote c'\4 \deadNote ees'\3 \deadNote bes'\2 \deadNote c''\1 >16
    < c'\4 ees'\3 bes'\2 c''\1 >16
    r8

    < c'\4 ees'\3 a'\2 c''\1 >8
    r8

    < c'\4 ees'\3 a'\2 c''\1 >16
    < c'\4 ees'\3 a'\2 c''\1 >16
    < \deadNote c'\4 \deadNote ees'\3 \deadNote a'\2 \deadNote c''\1 >16
    < \deadNote c'\4 \deadNote ees'\3 \deadNote a'\2 \deadNote c''\1 >16

    |
    % mesure Ab G
    <aes\5 c'\4 ees'\3 aes'\2 c''\1> 8
    <aes\5 c'\4 ees'\3 aes'\2 c''\1> 8

    <\deadNote aes\5 \deadNote c'\4 \deadNote ees'\3 \deadNote aes'\2 \deadNote c''\1> 16
    <aes\5 c'\4 ees'\3 aes'\2 c''\1> 16
    r8

    <\deadNote g\4 \deadNote b\3 \deadNote d'\2>16
    <\deadNote g\4 \deadNote b\3 \deadNote d'\2>16
    <g\4 b\3 d'\2>8

    <\deadNote g\4 \deadNote b\3 \deadNote d'\2>16
    <g\4 b\3 d'\2>8.



    |

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
