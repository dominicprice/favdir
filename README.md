# favdir.sh

Shortcut manager for bash.

## Installation

Place the `favdir.sh` script in an accessible location such as `$HOME/scripts`, and then
add the line
```
source /path/to/favdir.sh
```
in your `.bashrc` file

## Usage

`favdir.sh` manages a file (by default `~/.favdirs`) which contains a list of definitions
assigning paths to bash variables. To create a new entry, `cd` into the directory you want
to *fav* and type
```
favdir -c mynickname
```
where `mynickname` is any valid bash identifier. `favdir.sh` will then add the entry
`mynickname=/my/current/pwd` to `~/.favdirs` file and `source` this file so that you
can move into this directory with `cd $mynickname`. You can also move into the directory
by typing `favdir -g mynickname`. The `-g` (or `--go`) argument can take a partial entry
and if this is unique to one entry in database then it will take you there; therefore
if you have two entries `mynickname` and `yournickname`, `favdir -g mynick` will take
you to `mynickname`, but `favdir -g nick` is ambiguous and will just list the possible
options.

## Customizatioin

The location of the database is determined by the `$FAVDIR_DB` environment variable, and
defaults to `~/.favdirs`. To change this, simply define `FAVDIR_DB` to something else
before sourcing `favdir.sh`, e.g.
```
FAVDIR_DB=~/.config/favdirs`
source /path/to/favdir.sh
```