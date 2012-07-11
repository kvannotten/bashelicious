#!/bin/bash

##################################
# SSH Tunnel Bashelicious plugin #
##################################

sshtunnel() {
	BASENAME=sshtunnel
	USAGE="Usage: $BASENAME {-d [-f local port] | [-f local port] [-t remote port]} [...]"

	FROM=1080
	TO=1022
	DYNAMIC=false

	if [ "$#" -gt "0" ]
	then
		while getopts "hdf:t:" OPT
		do
			case "$OPT" in
				d)
					DYNAMIC=true
					;;
				f)
					FROM=$OPTARG
					;;
				t)
					TO=$OPTARG
					;;		
				h | *)
					echo $USAGE
					exit 1
					;;
			esac
		done
		shift $(($OPTIND-1))

		if [ "$DYNAMIC" == "true" ]
		then
			ssh -fND localhost:$FROM $@
		else
			ssh -fNL $FROM:localhost:$TO $@
		fi
	else
		echo $USAGE
	fi
}