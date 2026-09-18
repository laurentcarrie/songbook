using the song that is in current context ( currently edited, ask user if you don't have one ),
let D be the the directory of that song ( it is therefore a subdirectory of songs )
ask :
- the name of the new section
- after or before which existing section it should be positioned
- the type
and then :
- create the section in <D>/song.yml, at the correct position
- give it the relevant name and type
- in the <D>/lyrics folder, create the file <name>.tex if it does not exist