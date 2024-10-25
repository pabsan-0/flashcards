# Flashcards

Collection of flashcards to keep handy info a few keystrokes away.

## Setup  

```
# Install requirements
sudo apt install bat fzf

# Make bat accessible via command batcat (Ubuntu24 does by default)
ln -s /usr/bin/bat /usr/bin/batcat

# Optional: add syntax rules to batcat for better display
mkdir -p $(batcat --config-dir)/syntaxes
cp assets/flashcards.sublime-syntax $(batcat --config-dir)/syntaxes
batcat cache --build
```

## Usage

This repo is more about keeping a collection of quick-access notes, but does include a `./flashcards.bash` script for CLI control.

If you plan on using it, just link it into path: `ln -s $PWD/flashcards.bash /usr/bin/flashcards`

```
$ ./flashcards.bash --help
Usage: flashcards                        Interactive searh & display
                  <card_name>            Display flashcard by name
                  -a, --add <card_name>  Add new flashcar
                  -g, --git              In-context git commands
                  -s, --cd               Open project in subshell
```
