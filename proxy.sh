#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

# Function to log an error message
log_error() {
	local err="$1"
	printf "${RED}ERROR:${NORMAL} %s\n" "$err" >&2
}

if ! (return 0 2>/dev/null); then
	log_error "This script should be sourced, not executed directly."
	return
fi

config_file="${PROXY_SWITCHER_CONFIG:-$HOME}/.proxy.config"

# Function to extract a proxy setting from the configuration file
extract_var() {
	local key="$1"
	local result

	if ! result=$(sed -n -e "s/^.*${key}=\(.*\)$/\1/p" "${config_file}"); then
		log_error "cannot process config file"
		return 1
	fi

	printf "%s" "$result"
}

# Function to set the proxy
set_proxy() {
	local http_proxy https_proxy

	if ! http_proxy=$(extract_var 'HTTP_PROXY') || [ -z "$http_proxy" ]; then
		log_error "HTTP Proxy not found in configuration file"

		return 1
	fi

	if ! https_proxy=$(extract_var 'HTTPS_PROXY') || [ -z "$https_proxy" ]; then
		log_error "HTTPS Proxy not found in configuration file"
		return 1
	fi

	export HTTP_PROXY="$http_proxy"
	export HTTPS_PROXY="$https_proxy"

	printf "Switched proxy to %sON%s\n" "${RED}" "${NORMAL}"
}

# Function to unset the proxy
unset_proxy() {
	unset HTTP_PROXY HTTPS_PROXY

	printf "Switched proxy to %sOFF$%s\n" "${GREEN}" "${NORMAL}"
}

# Function to display the current proxy status
show_status() {
	if [ -z "$HTTP_PROXY" ]; then
		printf "HTTP Proxy is %sOFF%s\n" "${GREEN}" "${NORMAL}"
	else
		printf "HTTP Proxy is %sON%s\n" "${RED}" "${NORMAL}"
	fi

	if [ -z "$HTTPS_PROXY" ]; then
		printf "HTTPS Proxy is %sOFF%s\n" "${GREEN}" "${NORMAL}"
	else
		printf "HTTPS Proxy is %sON%s\n" "${RED}" "${NORMAL}"
	fi
}

# Function to display the current proxy settings
show_proxy() {
	http_proxy=$(extract_var 'HTTP_PROXY')
	https_proxy=$(extract_var 'HTTPS_PROXY')

	printf "HTTP Proxy is: %s\n" "${http_proxy:-'not configured'}"
	printf "HTTPS Proxy is: %s\n" "${https_proxy:-'not configured'}"
}

# Function to create or update the proxy configuration file
configure_proxy() {
	local new_http_proxy new_https_proxy input

	if [ -f "${config_file}" ]; then
		new_http_proxy=$(extract_var 'HTTP_PROXY')
		printf "Current HTTP Proxy is '%s'. Enter new HTTP Proxy (leave blank to keep current): " "${new_http_proxy}"
		read -r input
		if [ -n "$input" ]; then
			new_http_proxy=$input
		fi

		new_https_proxy=$(extract_var 'HTTPS_PROXY')
		printf "Current HTTPS Proxy is '%s'. Enter new HTTPS Proxy (leave blank to keep current): " "${new_https_proxy}"
		read -r input
		if [ -n "$input" ]; then
			new_https_proxy=$input
		fi
	else
		printf "Enter HTTP Proxy: "
		read -r new_http_proxy
		printf "Enter HTTPS Proxy: "
		read -r new_https_proxy
	fi

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
  show          : Show the current proxy environment variables.
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
        'show:Print the current proxy settings.'
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

# Main logic to process the command
case "$1" in
on)
	if [ ! -f "${config_file}" ]; then
		log_error "Configuration file not found. Please run \"proxy configure\" first."
		return
	fi

	set_proxy
	;;
off)
	unset_proxy
	;;
status)
	show_status
	;;
show)
	show_proxy
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
	log_error "unknown command '$1'\nUsage: source $0 {on|off|status|show|configure|completion|help}"
	;;
esac
