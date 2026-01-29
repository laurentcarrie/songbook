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


    % les numeros de mesure ici commencent
    % \set Score.currentBarNumber = #53

    % mesure #1
    r4 ees8\5 c'8\3~ c'8\3 ees8\5 d'4\3~
    % mesure #2
    d'4\3 ees8\5 c'8\3~ c'8\3 ees8\5 bes4\4~
    % mesure #3
    bes4\4 ees8\5 c'8\3~ c'8\3 ees8\5 d'4\3~
    % mesure #4
    d'4\3~ ees8\5 c'8\3~ c'8\3 ees8\5 bes4\4~
    % mesure #5
    bes4\4 c8\6 aes8\4~ aes8\4 bes,8\6 g4\4~
    % mesure #6
    g4\4 ees8\5 c'8\3~ c'8\3 d8\5 bes4\3~
    % mesure #7
    d4\5 c8\6 aes8\4~ aes8\4 bes,8\6 g4\4~
    % mesure #8
    g4\4 ees8\5 c'8\3~ c'8\3 bes,8\6 bes,4\6
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
    %    \new ChordNames {
    %     \song_chords
    %    }

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
