\version "2.20.0"


% Bb
ma = {

}

mg = {
  <g,\6 d\5 g\4>8
  <g,\6 d\5 g\4>8
  <g,\6 d\5 g\4>8
  r8
  <g,\6 d\5 g\4>8
  <g,\6 d\5 g\4>8
  <g,\6 d\5 g\4>8
  r8
}
mc = {
  <c\5 g\4 c'\3>8
  <c\5 g\4 c'\3>8
  <c\5 g\4 c'\3>8
  r8

  <c\5 g\4 c'\3>8
  <c\5 g\4 c'\3>8
  <c\5 g\4 c'\3>8
  r8
}
mf = {
  <f,\6 c\5 f\4>8
  <f,\6 c\5 f\4>8
  <f,\6 c\5 f\4>8
  r8
  <f,\6 c\5 f\4>8
  <f,\6 c\5 f\4>8
  <f,\6 c\5 f\4>8
  r8
}

lignea = {
  \mg | \mg | \mc | \mg |
}

ligneb = {
  \mc | \mc | \mf | \mf |
}



rhythm = {
  % une mesure pour la levée
  r1 |
  \mg
  \lignea
  \lignea
  \lignea
  \lignea
  \ligneb
}


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0


    % les numeros de mesure ici commencent

    %
    \mypull d'16\3 c'1\3
    |
    g'8\1 d'8\2 f'8~\2  f'8~\2 d'8\3 ais8\3 g8\4

  }

}

drumbar =  \drummode {  bd4 sn4  bd4 sn4 }

drumbars = {
  \repeat unfold 30 { \drumbar | }
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
  \repeat unfold 30 {  \drumbarhh }

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

  \layout {}
}
