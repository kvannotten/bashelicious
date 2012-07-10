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

### Tweaks

1. Modified CDPATH, so you can do cd DIRECTORY_IN_HOME_FOLDER anywhere
2. Colored the man pages
3. Modified some bash settings: ignore case, turn off the bell sound, single tab completion
4. Changed the prompt include username and path + the git branch you are currently working in, if you are in a git repository directory

## Credits

Some of these *tweaks* have been taken from random blogs. If you think you should be credited for a certain one, let me know and I will add your name here.
