\version "2.23.1"
\include "macros.ly"



lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1

    \repeat unfold 4 {
      % mesure 1
      <cis'\3 e'\2>8
      <cis'\3 e'\2>8
      <cis'\3 e'\2>8
      <b~\3 e'~\2>8
      <b\3 e'\2>2
      |
      % mesure 2
      <a\4 e'\3>8
      <a\4 e'\3>8
      <a\4 e'\3>8
      <gis~\4 e'~\3>8
      <gis\4 e'\3>2
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
