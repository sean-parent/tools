#!/usr/bin/osascript

(*
To use this script, install clang-format (the easiest way is to use Homebrew <https://brew.sh/>)

```bash
# install Homebrew
/usr/bin/ruby -e "$(curl -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install clang-format
brew install clang-format
```

Then add the script as a behavior in Xcode:

* Xcode->Behaviors->Edit Behaviors...
* Click (+) in lower left corner to add new behavior.
* Name the behavior "clang-format"
* Click on the (command) icon to add a command key (I use F1)
* Click the Run checkbox and the Choose Script... and select this script

Now you can select text in a source document in XCode and hit F1 (or whatever you chose) to format
that selection. You should make sure the code will compile first or your formatting may be wrong.
If you don't like the formatting, you can undo.
*)

on is_blank_line(_line)
	repeat with _char in _line
		if (_char is not tab) and (_char is not space) then return false
	end repeat
	return true
end is_blank_line

on last_blank_line_after(_lines, _index)
	if (_index is length of _lines) then return _index
	repeat with _index from _index + 1 to length of _lines
		if not is_blank_line(item _index of _lines) then return _index - 1
	end repeat
	return length of _lines
end last_blank_line_after

on last_blank_line_before(_lines, _index)
	if (_index is 1) then return 1
	repeat with _index from _index - 1 to 1 by -1
		if not is_blank_line(item _index of _lines) then return _index + 1
	end repeat
	return 1
end last_blank_line_before

on front_source_document()
	tell application "Xcode"
		set _name to name of front window
		repeat with _document in (source documents whose name is _name)
			if selected paragraph range of _document is not {} then return _document
		end repeat
		return null
	end tell
end front_source_document

tell application "Xcode"
	
	set _document to my front_source_document()
	
	if _document is null then
		display alert "clang-format failed." message "Could not find front document." buttons {"OK"} default button "OK"
		return
	end if
	
	set _source to paragraphs of (get text of _document)
	set _lines to length of _source
	
	set _range to selected paragraph range of _document
	set item 1 of _range to my last_blank_line_before(_source, item 1 of _range)
	set item 2 of _range to my last_blank_line_after(_source, item 2 of _range)
	
	set selected paragraph range of _document to _range
	
	set _path to path of _document
	
	try
		do shell script "/usr/local/bin/clang-format -lines=" & item 1 of _range & ":" & item 2 of _range & " " & quoted form of _path & "> /tmp/xcode-clang-format.tmp"
	on error error_message
		display alert "clang-format failed" message error_message buttons {"OK"} default button "OK"
		return
	end try
	
	set _result to read POSIX file "/tmp/xcode-clang-format.tmp"
	
	set _final_lines to length of paragraphs in _result
	
	set _f to item 1 of _range
	set _l to (item 2 of _range) + (_final_lines - _lines)
	
	set _replace to ""
	repeat with _line in paragraphs _f thru (_l - 1) of _result
		set _replace to _replace & _line & linefeed
	end repeat
	set _replace to _replace & paragraph _l of _result
	
	set the clipboard to _replace as text
	
	tell application "System Events"
		set frontmost of process "Xcode" to true
		keystroke "v" using command down
	end tell
	
	set _l to (item 2 of (get selected paragraph range of _document))
	
	if _l is not _f then
		set _l to _l - 1
	end if
	
	set selected paragraph range of _document to {_f, _l}
end tell
