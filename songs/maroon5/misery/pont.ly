\version "2.23.1"
\include "macros.ly"


song_chords = \chordmode {
  f1:m7 | ees1:maj7 | a1:dim | c1:m7 |
  f1:m7 | ees1:maj7 | a1:dim | a1:dim |
}


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1
    |
    % mesure 1
    <f\5 c'\4 ees'\3 aes'\2 c''\1>1

    |
    % mesure 2
    <ees\5 bes\4 d'\3 g'\2>1

    |
    %  mesure 3
    <d\5 aes\4 b\3 f'\2>1
    |

    % mesure 4
    <c\5 g\4 bes\3 ees'\2>1
    |

    % mesure 1
    <f\5 c'\4 ees'\3 aes'\2 c''\1>1

    |
    % mesure 2
    <ees\5 bes\4 d'\3 g'\2>1

    |
    %  mesure 3
    <d\5 aes\4 b\3 f'\2>1
    |

    % mesure 4
    <d\5 aes\4 b\3 f'\2>1
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
