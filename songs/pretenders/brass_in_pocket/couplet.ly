\version "2.23.1"
\include "macros.ly"


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1

    % mesure 1
    <cis'\3 e'\2>8
    <cis'\3 e'\2>8
    <cis'\3 e'\2>8
    <b~\3 e'~\2>8
    <b\3 e'\2>2
    |
    % mesure 2
    <a\4 d'\3>8
    <a\4 d'\3>8
    <a\4 d'\3>8
    <a~\4 cis'~\3>8
    <a\4 cis'\3>2
    |
    % mesure 3
    <cis'\3 e'\2>8
    <cis'\3 e'\2>8
    <cis'\3 e'\2>8
    <b~\3 e'~\2>8
    <b\3 e'\2>2
    |
    % mesure 4
    <a\4 d'\3>8
    <a\4 d'\3>8
    <a\4 d'\3>8
    <a~\4 cis'~\3>8
    <a\4 cis'\3>2
    |
    % mesure 5
    <cis'\3 e'\2>8
    <cis'\3 e'\2>8
    <cis'\3 e'\2>8
    <b~\3 e'~\2>8
    <b\3 e'\2>2
    |
    % mesure 6
    <a\4 d'\3>8
    <a\4 d'\3>8
    <a\4 d'\3>8
    <a~\4 cis'~\3 b~\2>8

    <a\4 cis'\3 b\2>8
    e'8\1
    b8\2
    cis'8\3
    |
    % mesure 7
    cis'8\3
    a16\4
    e'16\1~

    e'16\1
    b16\2
    cis'16\3
    d'16\3

    a16\4
    e'16\1
    b8\2

    cis'8\3
    a16\4
    e'16\1
    |
    % mesure 8
    b16\2
    cis'8.\3

    a16\4
    e'16\1
    b16\2
    cis'16\3

    cis'8.\3
    a16\4

    e'16\1
    b16\2
    cis'8\3
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
