\include "macros.ly"
\version "2.23.1"

song_chords = \chordmode {
  a1 a1 b1 b1 
}

basse = {
  \absolute  {
    \override Score.SpacingSpanner.shortest-duration-space = #4.0
    \set Score.currentBarNumber = 1

    \repeat unfold 2 {
    a,,4 a,,4 a,,4 a,,4 |
    b,,4 b,,4 b,,4 b,,4 |
    }

 
  }
}


  lead = {
    \absolute  {
      \override Score.SpacingSpanner.shortest-duration-space = #4.0
      \set Score.currentBarNumber = 1
  
  \repeat unfold 2 {
      e'8\3 a'8\2 b'8\1 cis''8\1~ |
      cis''8\1 cis''8\1 b'8\1 a'8\2 | 
  }

  \repeat unfold 2 {
      fis'8\2 a'8\2 b'8\1 cis''8\1~ |
      cis''8\1 cis''8\1 b'8\1 a'8\2 | 
  }


    }
  }

drumbar =  \drummode {  bd4 bd4  bd4 bd4 }
drumbars = {
  \repeat unfold 8 { \drumbar | }
}

drumbarsn =  \drummode {
  r8 r8  sn16 sn16 sn16 r16  r8 r8  sn16 sn16 sn16 r16  |

}
drumbarsn = {
  \repeat unfold 8 { \drumbarsn | }
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
% % 
% %     \new TabStaff {
% %       \tempo 4 = \songtempo
% %       \set Staff.stringTunings = #bass-tuning
% %       \tabFullNotation
% %       \override Score.BarNumber.break-visibility = ##(#t #t #t)
% %       %\clef bass
% %       \basse
% %     }

    \new DrumStaff {
      \tempo 4 = \songtempo
      <<
        %\new DrumVoice {  \drumbarshh }
        \new DrumVoice {  \drumbars }
        %\new DrumVoice { \drumbarsn }
      >>
    }


  >>

  \midi {
    \tempo 4 = \songtempo
  }
}
