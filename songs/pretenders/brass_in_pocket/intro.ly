\version "2.23.1"

\include "macros.ly"


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1

    <a\4 c'\3 d'\2>16
    r16
    r8
    r4
    r2
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

  %  #(add-text-replacements!
  %    '(
  %       ("100" . "hundred")
  %       ("dpi" . "dots per inch")
  %      ))

}


\score {
  <<
    \new TabStaff {
      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
    }

  >>

  \layout {
    #(layout-set-staff-size 20)
  }

  \midi{}
}
