using the song that is in current context ( currently edited, ask user if you don't have one ),
let D be the the directory of that song ( it is therefore a subdirectory of songs )
ask :
- the id of the new section ( e.g. refrain1 )
- the name of the new section ( its title, e.g. "refrain 1" )
- the position : after or before which existing section it should be positioned, or at the end ( after the last section )
- the kind of item : `!Chords` ( its own chords ) or `!Ref` ( a reference to an existing section, same chords )
- if `!Chords` :
  - the type
  - the rows ( chords, e.g. `| C | D G | C | D G |x2` )
- if `!Ref` :
  - the id of the section it links to ( e.g. couplet1 ), no type and no rows
and then :
- create the section in <D>/song.yml, at the correct position
- give it the relevant id, name ( title ) and item :
  - `!Chords` : title, type and rows
    ```yaml
    - id: <id>
      item: !Chords
        title: <name>
        type: <type>
        rows :
          - '<rows>'
    ```
  - `!Ref` : title and link
    ```yaml
    - id: <id>
      item: !Ref
        title: <name>
        link: <linked id>
    ```
- in the <D>/lyrics folder, create the file <id>.tex if it does not exist
