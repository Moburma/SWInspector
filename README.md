# SWInspector
Tool written in PowerShell 5 to inspect and edit level files from the Bullfrog Productions game Syndicate Wars

Can open, edit, and save all version 15+ format level files from the game (one level doesn't work, this is due to a non-standard commands header, may need special-casing). Pre-alpha levels are not supported yet, but may be later.
See here for level file versions: https://tcrf.net/Notes:Syndicate_Wars_(DOS)#Level_File_Versions

Most things in a level can already edited.

Full instructions will follow.

Hints:
* Click the left mouse button on the map to freeze the coordinates at current map position
* Top Coordinates are for Things, bottom are for Objectives/Netscan
* Clicking on a Thing jumps to that Thing's commands in the command window. Com > and < advances/moves back to the next Command in a chain, useful to understand complicated chains that jump around non-sequentially
* Advanced Mode shows ALL variables - otherwise these are hidden. Hidden ones are either rarely used or not used at all.
* If you added new Things to a level, make sure to use the "recalc parent/child" option on save, this recalculates all of these relations for you and is necessary for the level to work right (make sure you set unique ThingOffsets and UniqueID values)

![](https://github.com/Moburma/SWInspector/blob/main/SWMaps/screenshot.png?raw=true)

TODO:
* Stop copying chunks from the original files on save and create whole level file synthetically (close)
* Understand and implement the scratch/mounted guns area of files
* Understand and implement the starting camera angle and related bytes at the end of a file
* Come up with a better solution for vehicles, at the moment they are just treated as Person objects, which is wrong
* Nicer handling of Items, they don't have any helpers when editing yet (e.g. item picker combobox)
* ReWrite in an actually appropriate language
* Support for file extensions other than .DAT on saving
* Better map
* Import of Map Things to prevent ThingOffset collisions and also make it easier to see what building a command refers to/easier to set a new one
* Mods seem not quite right, some levels use odd values that don't make sense
