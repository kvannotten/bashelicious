# Bashelicious functions
function compress() { tar -jcvf "$@" ;}
function decompress() { tar -jxvf "$@" ;}
function findproc() { ps aux | grep -i $1 | grep -v grep ;}
function parse_git_branch_and_add_brackets {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'
}

function bashelicious {
	bold=`tput bold`;
	normal=`tput sgr0`;
	case "$1" in
		reload)
			[[ -e $HOME/.bashrc ]] && . $HOME/.bashrc
			;;
		list)
			echo "${bold}Plugins for Bashelicous${normal}";
			FILES="$HOME/.bashelicious/plugins"
			for i in $FILES/*
			do
				if [[ -f $i ]]; then
					j=${i##*/}
					j=${j%.plugin.sh}
					echo " [*] ${j}"
				fi
			done
			echo ""
			;;
		*)
			echo "Usage: ${bold}bashelicous${normal} {reload list}"
			;;
	esac
}