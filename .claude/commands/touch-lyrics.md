using the song that is in current context ( currently edited, ask user if you don't have one ),
let D be the the directory of that song ( it is therefore a subdirectory of songs )
then :
- read the `structure` list in <D>/song.yml
- every section whose item is `!Chords` or `!Ref` needs a lyrics file <D>/lyrics/<id>.tex, where <id> is the section's `id`
- `!NewColumn` and `!HRule` items have no lyrics file, skip them
- create <D>/lyrics if it does not exist
- for each missing <D>/lyrics/<id>.tex, create it as an empty file
- never modify or delete existing files, and do not touch lyrics files that match no section
- report the files created ( or that none were missing ), and list lyrics files that match no section
