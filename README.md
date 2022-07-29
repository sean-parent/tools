# tools

## xcode-clang-format.applescript

This is an osascript that can use `clang-format `to format a selection in xcode

### Installation

Install [Homebrew](https://brew.sh/):

```
/usr/bin/ruby -e "$(curl -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install [`clang-format`](https://clang.llvm.org/docs/ClangFormat.html):

```
brew install clang-format
```

Clone this repository:

```
cd <where-you-want-it>
git clone https://github.com/sean-parent/tools.git tools
```

Make the script executable:

```
chmod +x ./tools/xcode-clang-format.applescript
```

Add it as a behavior to Xcode:

![xcode-edit-behaviors](docs/images/xcode-edit-behaviors.gif)
![xcode-add-behavior](docs/images/xcode-add-behavior.gif)

You can add a command-key shortcut directly in Xcode or there is more flexibility if you add a shortcut through the keyboard system preferences (for example, I use f1 as my shortcut key).

Turn off _Syntax-aware indenting:_ in Xcode preferences:

![xcode-disable-indenting](docs/images/xcode-disable-indenting.png)

In System Preferences, allow Xcode to control you device and send System Events.

![image](https://user-images.githubusercontent.com/2279724/163095603-a7ec7398-458f-4f0e-80da-ebcb66f15a7c.png)

![image](https://user-images.githubusercontent.com/2279724/164563968-7c0c6eeb-91af-41fc-bfe7-5fb86811c4ba.png)

With some security software you may also need to allow Xcode to run software that doesn't meet the system's security policy.

![image](https://user-images.githubusercontent.com/2279724/181844680-9914dc02-9f5f-433f-aed2-7e9fb8ffb9d1.png)

**Note: The script has two hard coded keystrokes in it. One to save the document prior to formatting, and one to paste the formatted changes back into the document. If your command keys are mapped to something other than the US English defaults for these commands, you must modify the script. Find and edit these line:**

```
	my xcode_command("v") -- paste
```
```
	my xcode_command("s") -- save
```

## Usage

* The script uses the `-style=file` option for `clang-format`. It will find a `.clang-format` or `_clang-format` file in the same directy or any parent directory of the file you are formatting. Make sure you have an appropriate format file in place.
* **You can only have one instance of Xcode running**
* **Make sure you only have one tab, and one pane, open on the document you wish to format**
* Select an area of text you wish to format
* Select the `clang-format` behavior

Only the selected area is formatted.

![xcode-clang-format](docs/images/xcode-clang-format.gif)
