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

This script relies on sending key commands to the app - you must modify the script if your
key commands have been remapped.
*)

on xcode_command(key)
	tell application "System Events"
		set frontmost of process "Xcode" to true
		try
			keystroke key using command down
		on error message
			display dialog message
			error
		end try
	end tell
	delay 0.5 -- delay so system events don't cross Xcode events
end xcode_command

on paste(_text)
	-- delay 0.5 -- delay so system events don't cross Xcode events
	set the clipboard to _text
	my xcode_command("v") -- paste
end paste

on save_document()
	my xcode_command("s") -- save
end save_document

on is_blank_line(_line)
	repeat with _char in _line
		if ((id of _char) is not (id of tab)) and ((id of _char) is not (id of space)) then return false
	end repeat
	return true
end is_blank_line

on last_blank_line_after(_lines, _index)
	if (_index is length of _lines) then return _index
	if is_blank_line(item _index of _lines) then return _index
	repeat with _index from _index + 1 to length of _lines
		if is_blank_line(item _index of _lines) then return _index - 1
	end repeat
	return length of _lines
end last_blank_line_after

on last_blank_line_before(_lines, _index)
	if (_index is 1) then return 1
	if is_blank_line(item _index of _lines) then return _index
	repeat with _index from _index - 1 to 1 by -1
		if is_blank_line(item _index of _lines) then return _index + 1
	end repeat
	return 1
end last_blank_line_before

on line_count_without_trailing_empty_lines(_source)
	set _lines to (length of _source)
	if _lines = 0 then return 0
	
	repeat with _index from _lines to 1 by -1
		if item _index of _source ­ "" then
			return _index
		end if
	end repeat
	
	return 1
end line_count_without_trailing_empty_lines

on front_source_document()
	tell application "Xcode"
		set _window_name to name of front window
		repeat with _document in source documents
			if _window_name contains name of _document then
				return _document
			end if
		end repeat
		return null
	end tell
end front_source_document

try
	tell application "Xcode"
		
		set _document to my front_source_document()
		
		if _document is null then
			display alert "clang-format failed." message Â
				"Could not find front document." buttons {"OK"} default button "OK"
			return
		end if
		
		if selected paragraph range of _document is {} then
			display alert "clang-format failed." message Â
				"No selection found in front document." buttons {"OK"} default button "OK"
			return
		end if
		
		my save_document()
		
		set _source to paragraphs of (get text of _document)
		
		set _range to selected paragraph range of _document
		
		set item 1 of _range to my last_blank_line_before(_source, item 1 of _range)
		set item 2 of _range to my last_blank_line_after(_source, item 2 of _range)
		
		-- pin range to ignore empty blank lines
		
		set _source_lines to my line_count_without_trailing_empty_lines(_source)
		if item 1 of _range > _source_lines then return -- selection in trailing white space is ambigous
		if item 2 of _range > _source_lines then set item 2 of _range to _source_lines
		
		set selected paragraph range of _document to _range
		
		set _path to path of _document
		
		try
			do shell script "eval \"$(/usr/local/bin/brew shellenv)\";" & Â
				"clang-format " & Â
				"-lines=" & item 1 of _range & ":" & item 2 of _range & " " & Â
				quoted form of _path & " > /tmp/xcode-clang-format.tmp"
		on error error_message
			display alert "clang-format failed" message error_message buttons {"OK"} default button "OK"
			return
		end try
		
		set _result to paragraphs in (read POSIX file "/tmp/xcode-clang-format.tmp" as Çclass utf8È)
		
		set _result_lines to my line_count_without_trailing_empty_lines(_result)
		
		set _f to item 1 of _range
		set _l to (item 2 of _range) + (_result_lines - _source_lines)
		if _l > length of _result then set _l to length of _result
		if _f > _l then return -- selection was in trailing blank lines
		
		set _replace to item _f of _result
		if _f ­ _l then
			repeat with _line in items (_f + 1) thru _l of _result
				set _replace to _replace & linefeed & _line
			end repeat
		end if
		
		my paste(_replace as text)
		
		set _l to (item 2 of (get selected paragraph range of _document))
		
		set selected paragraph range of _document to {_f, _l}
	end tell
on error message
	display dialog message
	error
end try
