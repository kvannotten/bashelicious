###################################
# Bashelicious gnome proxy plugin #
###################################

function dequote() {
	echo $1 | sed -e "s|'||g"	
}

function desquarebracket() {
	echo $1 | sed -E -e "s/(\[|\])//g"
}

PROXY_MODE=$(gsettings get org.gnome.system.proxy mode)
if [[ $(dequote $PROXY_MODE) == "manual" ]]
then
	HTTP_HOST=$(dequote $(gsettings get org.gnome.system.proxy.http host))
	HTTP_PORT=$(gsettings get org.gnome.system.proxy.http port)

	HTTPS_HOST=$(dequote $(gsettings get org.gnome.system.proxy.https host))
	HTTPS_PORT=$(gsettings get org.gnome.system.proxy.https port)

	FTP_HOST=$(dequote $(gsettings get org.gnome.system.proxy.ftp host))
	FTP_PORT=$(gsettings get org.gnome.system.proxy.ftp port)

	IGNORE_HOSTS=$(desquarebracket "$(gsettings get org.gnome.system.proxy ignore-hosts)")

	export http_proxy="$HTTP_HOST:$HTTP_PORT"
	export https_proxy="$HTTPS_HOST:$HTTPS_PORT"
	export ftp_proxy="$FTP_HOST:$FTP_PORT"
	export no_proxy="$IGNORE_HOSTS"
fi

unset -f dequote
unset -f desquarebracket