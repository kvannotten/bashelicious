# Bashelicious

**Bashelicous** is a project that wants to encourage people to enhance their bash experience.
It is inspired by [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) but doesn't want to be a complete solution. 
**Bashelicious** wants to be a small solution with a few, small tweaks to greatly improve the encounters with bash, but not get in the way of existing configurations.

## Install

1. Checkout this repository
2. Run `setup install`
   * In OS X you have to edit the `~/.bash_profile` file and add the following line: `[[ -s ~/.bashrc ]] && source ~/.bashrc`

## Uninstall

1. Run `setup uninstall`

## Features

### Aliases

1. 'ls' aliases
   * 'll' instead of 'ls -FGlh'
   * 'la' instead of 'ls -FGlha'
2. 'tree' to show a treemap of your current directory
3. 'cd' aliases
   * '..' for 'cd ..'
   * '...' for 'cd ../..'
   * '-' for 'cd -'
4. Utilities
   * 'compress' to tar and gzip a file or directory
   * 'uncompress' to untar and ungzip a file
   * 'findproc' shorthand for a ps aux | grep ...
   * 'sshtunnel' to do ssh tunneling (-h for usage info)

### Tweaks

1. Modified CDPATH, so you can do cd DIRECTORY_IN_HOME_FOLDER anywhere
2. Colored the man pages
3. Changed the prompt include username and path + the git branch you are currently working in, if you are in a git repository directory
4. Added auto-completion for known hosts to the ssh command.
5. Proxy settings from Gnome will automatically be used whenever you open bash.
6. Modified some bash settings:
	- ignore case
	- turn off the bell sound
	- single tab completion
	- spelling correction for the 'cd' command
	- a shared history file for all shells
	- auto-expansion of bang (!) usages

### Plugins

Custom functionality can be added to Bashelicious using the plugin system. You can do so by adding files ending with '.plugin.sh' to the plugins folder (~/.bashelicious/plugins).
These will be sourced whenever a new terminal is started. Optionally you can manually source your .bashrc file.

## Credits

Some of these *tweaks* have been taken from random blogs. If you think you should be credited for a certain one, let me know and I will add your name here.
