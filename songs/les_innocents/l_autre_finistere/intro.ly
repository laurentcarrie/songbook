\include "macros.ly"
\version "2.23.1"

song_chords = \chordmode {
  a1 a1 b1 b1 
}



  lead = {
    \absolute  {
      \override Score.SpacingSpanner.shortest-duration-space = #4.0
      \set Score.currentBarNumber = 1
  
    \repeat percent 3 {
    g,8\6 g8\4 g,16\6 f16\4~ f16\4 g,16\6 e16\4 ~ e16\4 g,16\6 d16\4 ~ d16\4 g,16\6 bes,16\5 \glissando b,16\5 |
    }
    |
    f,8\6 f8\4 
    f,16\6 ees16\4~ ees16\4 f,16\6 
    d16\4 ~d16\4 f,16\6 c16\5 ~ 
    c16\5 f,16\6 bes,16\5 \glissando b,16\5 

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
