#!/usr/bin/env bash

# General methods

have()
{
    unset -v have
    # Completions for system administrator commands are installed as well in
    # case completion is attempted via `sudo command ...'.
    PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin type $1 &>/dev/null &&
    have="yes"
}

_get_comp_words_by_ref()
{
    local exclude flag i OPTIND=1
    local cur cword words=()
    local upargs=() upvars=() vcur vcword vprev vwords

    while getopts "c:i:n:p:w:" flag "$@"; do
        case $flag in
            c) vcur=$OPTARG ;;
            i) vcword=$OPTARG ;;
            n) exclude=$OPTARG ;;
            p) vprev=$OPTARG ;;
            w) vwords=$OPTARG ;;
        esac
    done
    while [[ $# -ge $OPTIND ]]; do 
        case ${!OPTIND} in
            cur)   vcur=cur ;;
            prev)  vprev=prev ;;
            cword) vcword=cword ;;
            words) vwords=words ;;
            *) echo "bash: $FUNCNAME(): \`${!OPTIND}': unknown argument" \
                1>&2; return 1
        esac
        let "OPTIND += 1"
    done

    __get_cword_at_cursor_by_ref "$exclude" words cword cur

    [[ $vcur   ]] && { upvars+=("$vcur"  ); upargs+=(-v $vcur   "$cur"  ); }
    [[ $vcword ]] && { upvars+=("$vcword"); upargs+=(-v $vcword "$cword"); }
    [[ $vprev  ]] && { upvars+=("$vprev" ); upargs+=(-v $vprev 
        "${words[cword - 1]}"); }
    [[ $vwords ]] && { upvars+=("$vwords"); upargs+=(-a${#words[@]} $vwords
        "${words[@]}"); }

    (( ${#upvars[@]} )) && local "${upvars[@]}" && _upvars "${upargs[@]}"
}

_get_cword()
{
    local LC_CTYPE=C
    local cword words
    __reassemble_comp_words_by_ref "$1" words cword

    # return previous word offset by $2
    if [[ ${2//[^0-9]/} ]]; then
        printf "%s" "${words[cword-$2]}"
    elif [[ "${#words[cword]}" -eq 0 || "$COMP_POINT" == "${#COMP_LINE}" ]]; then
        printf "%s" "${words[cword]}"
    else
        local i
        local cur="$COMP_LINE"
        local index="$COMP_POINT"
        for (( i = 0; i <= cword; ++i )); do
            while [[
                # Current word fits in $cur?
                "${#cur}" -ge ${#words[i]} &&
                # $cur doesn't match cword?
                "${cur:0:${#words[i]}}" != "${words[i]}"
            ]]; do
                # Strip first character
                cur="${cur:1}"
                # Decrease cursor position
                ((index--))
            done

            # Does found word matches cword?
            if [[ "$i" -lt "$cword" ]]; then
                # No, cword lies further;
                local old_size="${#cur}"
                cur="${cur#${words[i]}}"
                local new_size="${#cur}"
                index=$(( index - old_size + new_size ))
            fi
        done

        if [[ "${words[cword]:0:${#cur}}" != "$cur" ]]; then
            # We messed up! At least return the whole word so things
            # keep working
            printf "%s" "${words[cword]}"
        else
            printf "%s" "${cur:0:$index}"
        fi
    fi
} # _get_cword()

_get_pword() 
{
    if [ $COMP_CWORD -ge 1 ]; then
        _get_cword "${@:-}" 1;
    fi
}

_known_hosts_real()
{
    local configfile flag prefix
    local cur curd awkcur user suffix aliases i host
    local -a kh khd config

    local OPTIND=1
    while getopts "acF:p:" flag "$@"; do
        case $flag in
            a) aliases='yes' ;;
            c) suffix=':' ;;
            F) configfile=$OPTARG ;;
            p) prefix=$OPTARG ;;
        esac
    done
    [ $# -lt $OPTIND ] && echo "error: $FUNCNAME: missing mandatory argument CWORD"
    cur=${!OPTIND}; let "OPTIND += 1"
    [ $# -ge $OPTIND ] && echo "error: $FUNCNAME("$@"): unprocessed arguments:"\
    $(while [ $# -ge $OPTIND ]; do printf '%s\n' ${!OPTIND}; shift; done)

    [[ $cur == *@* ]] && user=${cur%@*}@ && cur=${cur#*@}
    kh=()

    # ssh config files
    if [ -n "$configfile" ]; then
        [ -r "$configfile" ] &&
        config=( "${config[@]}" "$configfile" )
    else
        for i in /etc/ssh/ssh_config "${HOME}/.ssh/config" \
            "${HOME}/.ssh2/config"; do
            [ -r $i ] && config=( "${config[@]}" "$i" )
        done
    fi

    # Known hosts files from configs
    if [ ${#config[@]} -gt 0 ]; then
        local OIFS=$IFS IFS=$'\n'
        local -a tmpkh
        # expand paths (if present) to global and user known hosts files
        # TODO(?): try to make known hosts files with more than one consecutive
        #          spaces in their name work (watch out for ~ expansion
        #          breakage! Alioth#311595)
        tmpkh=( $( awk 'sub("^[ \t]*([Gg][Ll][Oo][Bb][Aa][Ll]|[Uu][Ss][Ee][Rr])[Kk][Nn][Oo][Ww][Nn][Hh][Oo][Ss][Tt][Ss][Ff][Ii][Ll][Ee][ \t]+", "") { print $0 }' "${config[@]}" | sort -u ) )
        for i in "${tmpkh[@]}"; do
            # Remove possible quotes
            i=${i//\"}
            # Eval/expand possible `~' or `~user'
            __expand_tilde_by_ref i
            [ -r "$i" ] && kh=( "${kh[@]}" "$i" )
        done
        IFS=$OIFS
    fi

    if [ -z "$configfile" ]; then
        # Global and user known_hosts files
        for i in /etc/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts2 \
            /etc/known_hosts /etc/known_hosts2 ~/.ssh/known_hosts \
            ~/.ssh/known_hosts2; do
            [ -r $i ] && kh=( "${kh[@]}" $i )
        done
        for i in /etc/ssh2/knownhosts ~/.ssh2/hostkeys; do
            [ -d $i ] && khd=( "${khd[@]}" $i/*pub )
        done
    fi

    # If we have known_hosts files to use
    if [[ ${#kh[@]} -gt 0 || ${#khd[@]} -gt 0 ]]; then
        # Escape slashes and dots in paths for awk
        awkcur=${cur//\//\\\/}
        awkcur=${awkcur//\./\\\.}
        curd=$awkcur

        if [[ "$awkcur" == [0-9]*[.:]* ]]; then
            # Digits followed by a dot or a colon - just search for that
            awkcur="^$awkcur[.:]*"
        elif [[ "$awkcur" == [0-9]* ]]; then
            # Digits followed by no dot or colon - search for digits followed
            # by a dot or a colon
            awkcur="^$awkcur.*[.:]"
        elif [ -z "$awkcur" ]; then
            # A blank - search for a dot, a colon, or an alpha character
            awkcur="[a-z.:]"
        else
            awkcur="^$awkcur"
        fi

        if [ ${#kh[@]} -gt 0 ]; then
            # FS needs to look for a comma separated list
            COMPREPLY=( "${COMPREPLY[@]}" $( awk 'BEGIN {FS=","}
            /^\s*[^|\#]/ {for (i=1; i<=2; ++i) { \
            sub(" .*$", "", $i); \
            sub("^\\[", "", $i); sub("\\](:[0-9]+)?$", "", $i); \
            if ($i ~ /'"$awkcur"'/) {print $i} \
            }}' "${kh[@]}" 2>/dev/null ) )
        fi
        if [ ${#khd[@]} -gt 0 ]; then
            # Needs to look for files called
            # .../.ssh2/key_22_<hostname>.pub
            # dont fork any processes, because in a cluster environment,
            # there can be hundreds of hostkeys
            for i in "${khd[@]}" ; do
                if [[ "$i" == *key_22_$curd*.pub && -r "$i" ]]; then
                    host=${i/#*key_22_/}
                    host=${host/%.pub/}
                    COMPREPLY=( "${COMPREPLY[@]}" $host )
                fi
            done
        fi

        # apply suffix and prefix
        for (( i=0; i < ${#COMPREPLY[@]}; i++ )); do
            COMPREPLY[i]=$prefix$user${COMPREPLY[i]}$suffix
        done
    fi

    # append any available aliases from config files
    if [[ ${#config[@]} -gt 0 && -n "$aliases" ]]; then
        local hosts=$( sed -ne 's/^[ \t]*[Hh][Oo][Ss][Tt]\([Nn][Aa][Mm][Ee]\)\{0,1\}['"$'\t '"']\{1,\}\([^#*?]*\)\(#.*\)\{0,1\}$/\2/p' "${config[@]}" )
        COMPREPLY=( "${COMPREPLY[@]}" $( compgen  -P "$prefix$user" \
            -S "$suffix" -W "$hosts" -- "$cur" ) )
    fi

    # Add hosts reported by avahi-browse, if desired and it's available.
    if [[ ${COMP_KNOWN_HOSTS_WITH_AVAHI:-} ]] && \
        type avahi-browse &>/dev/null; then
        # The original call to avahi-browse also had "-k", to avoid lookups
        # into avahi's services DB. We don't need the name of the service, and
        # if it contains ";", it may mistify the result. But on Gentoo (at
        # least), -k wasn't available (even if mentioned in the manpage) some
        # time ago, so...
        COMPREPLY=( "${COMPREPLY[@]}" $( \
            compgen -P "$prefix$user" -S "$suffix" -W \
            "$( avahi-browse -cpr _workstation._tcp 2>/dev/null | \
                 awk -F';' '/^=/ { print $7 }' | sort -u )" -- "$cur" ) )
    fi

    # Add results of normal hostname completion, unless
    # `COMP_KNOWN_HOSTS_WITH_HOSTFILE' is set to an empty value.
    if [ -n "${COMP_KNOWN_HOSTS_WITH_HOSTFILE-1}" ]; then
        COMPREPLY=( "${COMPREPLY[@]}"
            $( compgen -A hostname -P "$prefix$user" -S "$suffix" -- "$cur" ) )
    fi

    __ltrim_colon_completions "$prefix$user$cur"

    return 0
} # _known_hosts_real()

__get_cword_at_cursor_by_ref() {
    local cword words=()
    __reassemble_comp_words_by_ref "$1" words cword

    local i cur2
    local cur="$COMP_LINE"
    local index="$COMP_POINT"
    for (( i = 0; i <= cword; ++i )); do
        while [[
            # Current word fits in $cur?
            "${#cur}" -ge ${#words[i]} &&
            # $cur doesn't match cword?
            "${cur:0:${#words[i]}}" != "${words[i]}"
        ]]; do
            # Strip first character
            cur="${cur:1}"
            # Decrease cursor position
            ((index--))
        done

        # Does found word matches cword?
        if [[ "$i" -lt "$cword" ]]; then
            # No, cword lies further;
            local old_size="${#cur}"
            cur="${cur#${words[i]}}"
            local new_size="${#cur}"
            index=$(( index - old_size + new_size ))
        fi
    done

    if [[ "${words[cword]:0:${#cur}}" != "$cur" ]]; then
        # We messed up. At least return the whole word so things keep working
        cur2=${words[cword]}
    else
        cur2=${cur:0:$index}
    fi

    local "$2" "$3" "$4" && 
        _upvars -a${#words[@]} $2 "${words[@]}" -v $3 "$cword" -v $4 "$cur2"
}

_upvars() {
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                [[ "$2" ]] && unset -v "$2" && eval $2=\(\"\${@:3:${1#-a}}\"\) && 
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                [[ "$2" ]] && unset -v "$2" && eval $2=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}

__reassemble_comp_words_by_ref() {
    local exclude i j ref
    # Exclude word separator characters?
    if [[ $1 ]]; then
        # Yes, exclude word separator characters;
        # Exclude only those characters, which were really included
        exclude="${1//[^$COMP_WORDBREAKS]}"
    fi
        
    # Default to cword unchanged
    eval $3=$COMP_CWORD
    # Are characters excluded which were former included?
    if [[ $exclude ]]; then
        # Yes, list of word completion separators has shrunk;
        # Re-assemble words to complete
        for (( i=0, j=0; i < ${#COMP_WORDS[@]}; i++, j++)); do
            # Is current word not word 0 (the command itself) and is word not
            # empty and is word made up of just word separator characters to be
            # excluded?
            while [[ $i -gt 0 && ${COMP_WORDS[$i]} && 
                ${COMP_WORDS[$i]//[^$exclude]} == ${COMP_WORDS[$i]} 
            ]]; do
                [ $j -ge 2 ] && ((j--))
                # Append word separator to current word
                ref="$2[$j]"
                eval $2[$j]=\${!ref}\${COMP_WORDS[i]}
                # Indicate new cword
                [ $i = $COMP_CWORD ] && eval $3=$j
                # Indicate next word if available, else end *both* while and for loop
                (( $i < ${#COMP_WORDS[@]} - 1)) && ((i++)) || break 2
            done
            # Append word to current word
            ref="$2[$j]"
            eval $2[$j]=\${!ref}\${COMP_WORDS[i]}
            # Indicate new cword
            [[ $i == $COMP_CWORD ]] && eval $3=$j
        done
    else
        # No, list of word completions separators hasn't changed;
        eval $2=\( \"\${COMP_WORDS[@]}\" \)
    fi
} # __reassemble_comp_words_by_ref()

__ltrim_colon_completions() {
    # If word-to-complete contains a colon,
    # and bash-version < 4,
    # or bash-version >= 4 and COMP_WORDBREAKS contains a colon
    if [[
        "$1" == *:* && (
            ${BASH_VERSINFO[0]} -lt 4 || 
            (${BASH_VERSINFO[0]} -ge 4 && "$COMP_WORDBREAKS" == *:*) 
        )
    ]]; then
        # Remove colon-word prefix from COMPREPLY items
        local colon_word=${1%${1##*:}}
        local i=${#COMPREPLY[*]}
        while [ $((--i)) -ge 0 ]; do
            COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
        done
    fi
} # __ltrim_colon_completions()

_compopt_o_filenames()
{
    # We test for compopt availability first because directly invoking it on
    # bash < 4 at this point may cause terminal echo to be turned off for some
    # reason, see https://bugzilla.redhat.com/653669 for more info.
    type compopt &>/dev/null && compopt -o filenames 2>/dev/null || \
        compgen -f /non-existing-dir/ >/dev/null
}

_expand()
{
    # FIXME: Why was this here?
    #[ "$cur" != "${cur%\\}" ] && cur="$cur\\"

    # Expand ~username type directory specifications.  We want to expand
    # ~foo/... to /home/foo/... to avoid problems when $cur starting with
    # a tilde is fed to commands and ending up quoted instead of expanded.

    if [[ "$cur" == \~*/* ]]; then
        eval cur=$cur
    elif [[ "$cur" == \~* ]]; then
        cur=${cur#\~}
        COMPREPLY=( $( compgen -P '~' -u "$cur" ) )
        [ ${#COMPREPLY[@]} -eq 1 ] && eval COMPREPLY[0]=${COMPREPLY[0]}
        return ${#COMPREPLY[@]}
    fi
}
