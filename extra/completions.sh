#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" )"

if [[ -f $DIR/completions_helpers.sh ]]; then
	. $DIR/completions_helpers.sh
	
	# add extra files depending on helpers here
	if [[ -f $DIR/completions_ssh.sh ]]; then
		. $DIR/completions_ssh.sh
	fi
fi