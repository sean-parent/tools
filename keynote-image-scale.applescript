tell application "Keynote"
	tell last image of current slide of front document
		set width to 3 * width
	end tell
end tell