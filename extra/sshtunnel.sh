#!/bin/bash
BASENAME=sshtunnel

FROM=1080
TO=1022
DYNAMIC=false

print_usage() {
	echo "Usage: $BASENAME {-d [-f local port] | [-f local port] [-t remote port]} [...]";
	exit 1;
}

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
				print_usage
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
	print_usage
fi
