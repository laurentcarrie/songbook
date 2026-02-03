\version "2.23.1"


\include "macros.ly"

song_chords = \chordmode {
  a1|a1|a1|a1|a1|a1|
  d1|d1|d1|d1|d1|d1|

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


lead = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1
    \repeat unfold 3 {
      <a,\5 e\4 a\3 cis'\2>4.
      dis'8~
      dis'4
      cis'4
      |
      r8
      <a,\5 e\4 a\3 cis'\2>8
      g,8
      <e\4 a\3>8
      c8 a,8
      g,8
      <a,\5 e\4 a\3 cis'\2>8
    }

    \repeat unfold 3 {
      <d\4 d'\3 g'\2>4.
      <d\4 d'\3 fis'\2>8~
      <d\4 d'\3 fis'\2>4
      <d\4 c'\3 f'\2>4~
      |
      <d\4 c'\3 f'\2>8
      <d\4 c'\3 e'\2>8~
      <d\4 c'\3 e'\2>4
      r4
      r4
      |

    }




  }
}

drumbar =  \drummode {  bd4 sn4  bd4 sn4 }
drumbars = {
  \repeat unfold 8 { \drumbar | }
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
  \repeat unfold 8 {  \drumbarhh }

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
