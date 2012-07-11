# Bashelicious functions
function compress() { tar -jcvf "$@" ;}
function decompress() { tar -jxvf "$@" ;}
function findproc() { ps aux | grep -i $1 | grep -v grep ;}
function parse_git_branch_and_add_brackets {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'
}