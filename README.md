# Bashelicious

**Bashelicous** is a project that wants to encourage people to enhance their bash experience.
It is inspired by [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) but doesn't want to be a complete solution. 
**Bashelicious** wants to be a small solution with a few, small tweaks to greatly improve the encounters with bash, but not get in the way of existing configurations.

## Install

1. Checkout this repository
2. Run `rake install` in the **Bashelicious** directory

## Uninstall

1. Run `rake uninstall` in the **Bashelicious** directory

## Features

### Aliases

1. 'ls' aliases
   * 'll' instead of 'ls -FGlh'
   * 'la' instead of 'ls -FGlha'
   * 'l' instead of 'ls -FG'
2. 'tree' to show a treemap of your current directory
5. '..' for 'cd ..'
6. '...' for 'cd ../..'
7. '-' for 'cd -'
8. 'compress' to tar and gzip a file or directory
9. 'uncompress' to do the opposite of *8*

### Tweaks

1. Modified CDPATH, so you can do cd DIRECTORY_IN_HOME_FOLDER anywhere
2. Colored the man pages
3. Modified some bash settings: ignore case, turn off the bell sound, single tab completion
4. Changed the prompt include username and path + the git branch you are currently working in, if you are in a git repository directory

## Credits

Some of these *tweaks* have been taken from random blogs. If you think you should be credited for a certain one, let me know and I will add your name here.