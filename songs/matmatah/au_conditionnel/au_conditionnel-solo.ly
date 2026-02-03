\include "macros.ly"
\version "2.20.0"

\paper {
  indent = 0\mm
  line-width = 210\mm
  oddHeaderMarkup = ""
  evenHeaderMarkup = ""
  oddFooterMarkup = ""
  evenFooterMarkup = ""
}



ma = {
  < e' gis' b' e'' >
  < e' gis' b' e'' >
  < cis' gis' cis'' e''  >
  < cis' gis' cis'' e''  >
}

mb = {
  < gis dis' gis' b' dis'' >
  < gis dis' gis' b' dis'' >
  < b fis' b' dis'  >
  < b fis' b' dis'  >
}

mc = {
  < e' gis' b' e'' >
  < e' gis' b' e'' >
  < gis dis' gis' b' dis'' >
  < gis dis' gis' b' dis'' >
}

md = {
  <a e' a' cis' >
  <a e' a' cis' >
  <a e' a' cis' >
  <a e' a' cis' >
}


rhythm = {
  \ma \mb \mc \md
  \ma \mb \mc \md
}

lead = {
  r8 b\3 cis'\3  fis'\2 gis'  e'\2 cis'4\3
  |
  dis'4.\3 b8\3 dis' b\3 r4
  |
  r8 b\3 cis'\3  fis'\2 gis'  e'\2 c'4\3
  |
  cis'4.\3 cis'8\3 e'8\2 r8 a'8 gis'
  |
  e'1\2

}


drumbar =  \drummode {  bassdrum4 hihat4  bassdrum hihat }

\score {

  <<

    \new DrumStaff {

      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |
      \drumbar |



    }


    \new Staff {
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      %\set TabStaff.stringTunings = #custom-tuning
      \rhythm
    }

    \new Staff	 {
      \clef "treble_8"
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
    }

    \new TabStaff {
      \override Score.BarNumber.break-visibility = ##(#t #t #t)
      \lead
    }



  >>
  \layout {}

  \midi {}
}
