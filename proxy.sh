#!/bin/bash

# Configuration file path
config_file="${PROXY_SWITCHER_CONFIG:-$HOME}/.proxy.config"

# Function to extract a proxy setting from the configuration file
extract_proxy() {
	local key="$1"
	local result=$(sed -n -e "s/^${key}=\(.*\)$/\1/p" "${config_file}")

	echo "$result"
}

# Function to set the proxy
set_proxy() {
	local http_proxy=$(extract_proxy 'HTTP_PROXY')
	if [ -z "$http_proxy" ]; then
		printf "\e[31mERROR:\e[0m HTTP Proxy not found in configuration file\n"
		return 1
	fi

	local https_proxy=$(extract_proxy 'HTTPS_PROXY')
	if [ -z "$https_proxy" ]; then
		printf "\e[31mERROR:\e[0m HTTPS Proxy not found in configuration file\n"
		return 1
	fi

	export HTTP_PROXY="$http_proxy"
	export HTTPS_PROXY="$https_proxy"

	printf "Switched proxy to \e[31mON\e[0m\n"
}

# Function to unset the proxy
unset_proxy() {
	unset HTTP_PROXY HTTPS_PROXY
	printf "Switched proxy to \e[32mOFF\e[0m\n"
}

# Function to display the current proxy status
show_status() {
	if [ -z "$HTTP_PROXY" ]; then
		printf "HTTP Proxy is \e[32mOFF\e[0m\n"
	else
		printf "HTTP Proxy is \e[31mON\e[0m\n"
	fi

	if [ -z "$HTTPS_PROXY" ]; then
		printf "HTTPS roxy is \e[32mOFF\e[0m\n"
	else
		printf "HTTPS Proxy is \e[31mON\e[0m\n"
	fi

}

# Function to create or update the proxy configuration file
configure_proxy() {
	local new_http_proxy new_https_proxy input

	# Check if the config file already exists
	if [ -f "${config_file}" ]; then
		# HTTP Proxy
		new_http_proxy=$(extract_proxy 'HTTP_PROXY')
		echo -n "Current HTTP Proxy is '${new_http_proxy}'. Enter new HTTP Proxy (leave blank to keep current): "
		read -r input
		if [ -n "$input" ]; then
			new_http_proxy=$input
		fi

		# HTTPS Proxy
		new_https_proxy=$(extract_proxy 'HTTPS_PROXY')
		echo -n "Current HTTPS Proxy is '${new_https_proxy}'. Enter new HTTPS Proxy (leave blank to keep current): "
		read -r input
		if [ -n "$input" ]; then
			new_https_proxy=$input
		fi
	else
		echo -n "Enter HTTP Proxy: "
		read -r new_http_proxy
		echo -n "Enter HTTPS Proxy: "
		read -r new_https_proxy
	fi

	# Write to config file
	echo "HTTP_PROXY=${new_http_proxy}" >"${config_file}"
	echo "HTTPS_PROXY=${new_https_proxy}" >>"${config_file}"

	echo "Proxy configuration updated."
}

show_help() {
	cat <<EOF
Usage: proxy [command]

Commands:
  on            : Set the proxy environment variables.
  off           : Unset the proxy environment variables.
  status        : Print the current proxy status.
  configure     : Starts the configuration wizard.
  completion    : Generate completion script for bash or zsh.
  help          : Display this help message.
EOF
}

sho_bash_completion() {
	cat <<EOF
_proxy() {
    local cur=\${COMP_WORDS[COMP_CWORD]}
    case \${COMP_CWORD} in
        1)
            COMPREPLY=( \$(compgen -W "on off status show configure completion help" -- \$cur) )
            ;;
        2)
            if [ \${COMP_WORDS[1]} = "completion" ]; then
                COMPREPLY=( \$(compgen -W "bash zsh" -- \$cur) )
            fi
            ;;
    esac
    return 0
}
complete -F _proxy proxy
EOF
}

show_zsh_completion() {
	cat <<EOF
  _proxy() {
    local -a main_commands
    main_commands=(
        'on:Set the proxy environment variables.'
        'off:Unset the proxy environment variables.'
        'status:Print the current proxy status.'
        'configure:Starts the configuration wizard.'
        'completion:Generate completion script.'
        'help:Display the help message.'
    )
    local -a completion_commands
    completion_commands=(
        'bash:Generate bash completion script.'
        'zsh:Generate zsh completion script.'
    )
    case "\$words[2]" in
        on|off|status|show|configure)
            return
            ;;
        completion)
            _describe -t commands -V "completion options" completion_commands && return
            ;;
        *)
            _describe -t commands -V "proxy commands" main_commands && return
            ;;
    esac
}
EOF
}

# Check for the existence of the configuration file
if [ ! -f "${config_file}" ]; then
	echo "Configuration file not found. Please run \"proxy configure\" first."
	return
fi

# Main logic to process the command
case "$1" in
on)
	set_proxy
	;;
off)
	unset_proxy
	;;
status)
	show_status
	;;
configure)
	configure_proxy
	;;
completion)
	case "$2" in
	bash)
		show_bash_completion
		;;
	zsh)
		show_zsh_completion
		;;
	esac
	;;
help)
	show_help
	;;
*)
	printf "\e[31mERROR:\e[0m unknown command '$1'\nUsage: source $0 {on|off|status|configure|completion|help}\n"
	;;
esac
