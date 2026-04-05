#!/bin/bash

# Simple file picker wrapper for the compress script

# Use AppleScript to open file picker
osascript << 'APPLESCRIPT'
set chosenItems to choose file with multiple selections allowed with prompt "Select images or folders to compress:"
set scriptPath to "/Users/jack/Documents/GitHub/quick-compress/compress-images.sh"

repeat with anItem in chosenItems
	set itemPath to POSIX path of anItem
	do shell script "\"" & scriptPath & "\" \"" & itemPath & "\""
end repeat

display notification "All images compressed!" with title "Compress Images"
APPLESCRIPT
