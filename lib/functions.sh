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
	PLUGINSTATUS=$BASHELICIOUS_DIR/plugins/.disabled
	
	case "$1" in
		reload)
			[[ -e $HOME/.bashrc ]] && . $HOME/.bashrc
			if [[ -f $PLUGINSTATUS ]]; then
				echo "${bold}The following plugins are disabled:${normal}"
				while read p; do
					echo $p
				done < $PLUGINSTATUS 
			fi
			;;
		plugins)
			if [[ -z $2 && -z $3 ]]; then
				echo "Usage: ${bold}bashelicious plugins${normal} { list | enable | disable }";
				return;
			fi
			
			case "$2" in
				list)
					echo "${bold}Plugins for Bashelicous${normal}";
					FILES="$BASHELICIOUS_DIR/plugins"
					for i in $FILES/*
					do
						if [[ -f $i ]]; then
							j=${i##*/}
							j=${j%.plugin.sh}
							if [[ -f $PLUGINSTATUS && ! -z $(cat $PLUGINSTATUS | grep $j) ]]; then
								echo " [ ] ${j}"
							else
								echo " [*] ${j}"
							fi
						fi
					done
					;;
				enable)
					if [[ -f $PLUGINSTATUS ]]; then
						echo "Enabling plugin $3"
						sed -i -e /$3/d $PLUGINSTATUS
					fi
				;;
				
				disable)
					if [[ ! -f $PLUGINSTATUS ]]; then
						touch $PLUGINSTATUS
					fi
					echo "Disabling plugin $3"
					echo $3 >> $PLUGINSTATUS;
					echo "You have to restart your terminal for the changes to take effect."
				;;
				*)
				echo "Usage: ${bold}bashelicious plugins${normal} { list | enable | disable }"
				;;
			esac
			;;
		*)
			echo "Usage: ${bold}bashelicous${normal} { reload | plugins}"
			;;
	esac
}