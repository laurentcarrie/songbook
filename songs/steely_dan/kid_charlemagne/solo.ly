\version "2.23.1"
\include "macros.ly"

songtempo=114

song_chords = \chordmode {
  a1|a1|a1|a1|a1|a1|
  d1|d1|d1|d1|d1|d1|

}


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


song_chords = \chordmode {
  a1:| d1:m7 | f1 | bes2:dim e2:7 |
  a1:m | g1:6 | f1:maj7 | c1:6 | d2:m7 b2:7 |
  e1:m7 | d1:6 | c1:maj7 | e2:m7 b2:m7 |
  a1:m | g1:6 | f1:6-9 | bes1:13 |
  f1 | g1 | a1:m | g1:6 | d1:m7 | g1:6 | f1:6 |
  e1:m7 | f1:maj7 | e1:m7 | d1:m7
}


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \override NoteHead.color = #red


    % les numeros de mesure ici commencent

    % mesure
    %\set Score.currentBarNumber = #53
    %\staffHighlight "lightsteelblue"

    \repeat unfold 20 {
      r1 |
    }

  }
}


basse = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1

    \repeat unfold 6 {
      a,,8\3 a,,8\3 a,,8\3 a,,8\3 a,,8\3 a,,8\3 a,,8\3 a,,8\3 |
    }
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

    %    \new TabStaff {
    %      \tempo 4 = \songtempo
    %      \set Staff.stringTunings = #bass-tuning
    %      \tabFullNotation
    %      \override Score.BarNumber.break-visibility = ##(#t #t #t)
    %      %\clef bass
    %      \basse
    %    }
    %

  >>

  \layout {}
}


\score {
  <<
    %    \new ChordNames {
    %      \song_chords
    %    }

    \new TabStaff {
      \tempo 4 = \songtempo
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
    }

    \new TabStaff {
      \tempo 4 = \songtempo
      \set Staff.stringTunings = #bass-tuning
      \tabFullNotation
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      %\clef bass
      \basse
    }

    \new DrumStaff {
      \tempo 4 = \songtempo
      <<
        \new DrumVoice {  \drumbarshh }
        \new DrumVoice {  \drumbars }
      >>
    }


  >>

  \midi {
    \tempo 4 = \songtempo
  }
}
