\version "2.23.1"
\include "macros.ly"

% a new comment

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
  d1:m | d1:m |
  g1:m | a1:m | d1:m | d1:m |
  g1:m | ees1 | bes1 |
}


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0


    % les numeros de mesure ici commencent
    \set Score.currentBarNumber = #53

    % mesure #1
    \tuplet 3/2 {
      r4
      f8\4
    }
    \tuplet 3/2 {
      c'8\glissando\3 d'8\3
      d'4~\3
      ~8\3 r8 d'8\3\glissando c'8\3 a8\4
    }


    % mesure #2
    |
    \tuplet 3/2 {
      f'8\2 d'8\3 d'8\3~
    }
    \tuplet 3/2 {
      d'4\3 f8\5
    }

    \tuplet 3/2 {
      d'8\3 c'8\3 g8\4
    }
    \tuplet 3/2 {
      f8\3
      d8\5 c8\5
    }


    % mesure #3
    |
    \( \grace f8\4~\glissando g1\4 \prall \)
    % mesure #4
    |
    r1
    % mesure #5
    |
    r4
    \tuplet 3/2 {
      \grace g'8\2\glissando a'8\2 c''8\1 c''8\1
    }
    \tuplet 3/2 {
      \grace a'10\2\glissando g'8\2 f'8\2 d'8\3
    }
    \tuplet 3/2{
      g'8\2\glissando a'8\2 c''8\1
    }

    % mesure #6
    |
    \tuplet 3/2 {
      d''4\1 c''8\1~
    }
    \tuplet 3/2 {
      c''8\1 \glissando g'4\2
    }
    \tuplet 3/2 {
      f'4\2 \grace g'8\2\^ a'\2
    }
    \tuplet 3/2 {
      r8 f'8\2 d'8\3
    }

    % mesure #7
    |
    \( \grace f'8\2~\glissando g'1\2~ \prall \)
    % mesure #3

    % mesure 8
    |
    \( g'1\2~ \prall \)

    % mesure 9
    |
    r1
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

\score {
  \unfoldRepeats {
    <<
      \new DrumStaff
      \tempo 4 = \songtempo
      <<
        \new DrumVoice {  \drumbarshh }
        \new DrumVoice {  \drumbars }
      >>

      \new Staff {
        \rhythm
        \set Staff.midiMinimumVolume = #0.2
        \set Staff.midiMaximumVolume = #0.2
        %\set Staff.midiInstrument = "electric guitar (clean)"
        %\set Staff.midiInstrument = "bass"
        %\set Staff.midiInstrument = "clarinet"
      }
      \new Staff {
        \lead
        \set Staff.midiMinimumVolume = #0.9
        \set Staff.midiMaximumVolume = #0.9
        \set Staff.midiInstrument = "electric guitar (clean)"
      }
      %\new Staff {
      %      \song_voice
      %      \set Staff.midiMinimumVolume = #0.9
      %      \set Staff.midiMaximumVolume = #0.9
      %      \set Staff.midiInstrument = "electric guitar (clean)"
      %}
    >>
  }
  \midi {
    \tempo 4 = \songtempo
  }
}
