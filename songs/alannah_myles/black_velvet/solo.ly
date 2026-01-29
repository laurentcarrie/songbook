\version "2.23.1"
\include "macros.ly"

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
    \override NoteHead.color = #red


    % les numeros de mesure ici commencent

    % mesure
    \set Score.currentBarNumber = #53
    \staffHighlight "lightsteelblue"

    <>^"default"
    r4
    \override Beam.color = #red
    \override NoteHead.color = #red
    \override Stem.color = #red

    g'16\^\2 ais'16\^\2 g'16\2 \glissando
    f'16\2

    d'4\3~

    \tuplet 3/2
    {
      d'8\3 d'8\3 c'8\3
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
      \override TextScript.font-size = -2
      \clef "G_8"
      \tabFullNotation
      \set Score.currentBarNumber = #53

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
