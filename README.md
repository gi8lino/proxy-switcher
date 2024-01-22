# Proxy Switcher Script

A bash script to easily set, unset, and manage proxy settings in your environment.

## Table of Contents

- [Proxy Switcher Script](#proxy-switcher-script)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Commands](#commands)
  - [Setup](#setup)
    - [Config File](#config-file)
    - [Bash Completion](#bash-completion)
    - [Zsh Completion](#zsh-completion)
  - [Examples](#examples)
  - [Contributing](#contributing)
  - [License](#license)

## Usage

```bash
proxy [command]
```

## Commands

- **on**: Set the proxy environment variables.
- **off**: Unset the proxy environment variables.
- **status**: Print the current proxy status.
- **show**: Display the current proxy environment variables.
- **configure**: Starts the configuration wizard.
- **completion**: Generate a completion script for `bash` or `zsh`.
- **help**: Display the help message.

## Setup

The `proxy.sh` script is designed to modify the environment variables of your current shell session, specifically to set or unset proxy settings. To achieve this, the script needs to be executed within the context of the current shell, not as a separate subprocess. This is where sourcing the script (using `source` or `.`) becomes essential.

### Config File

To configure the proxy, create a `.proxy.conf` file in your `$HOME` directory or specify its location using the `PROXY_SWITCHER_CONFIG` environment variable.

The configuration must contain the following two variables:

```text
HTTP_PROXY=http://proxy.company.com:PORT
HTTPS_PROXY=http://proxy.company.com:PORT
```

### Alias

Create a alias in your `.bashrc` or `.zshrc` file:

#### Bash

```bash
function proxy_script() {
    source /path/to/proxy.sh "\$@"
}
alias proxy=proxy_script
```

#### Zsh

```sh
function proxy() {
    source /path/to/proxy.sh "\$@"
}
```

### Bash Completion

Enable auto-completion for Bash with:

```bash
source <(proxy completion bash)
```

### Zsh Completion

For Zsh auto-completion, run:

```bash
. <(proxy completion zsh) && compdef _proxy proxy
```

## Examples

```bash
# Set the proxy:
proxy on

# Unset the proxy:
proxy off

# Check the proxy status:
proxy status

# Show the current proxy settings:
proxy show

# Show completion for bash:
proxy completion bash

# Show completion for zsh:
proxy completion zsh
```

## Contributing

Contributions are welcome! Fork the repository, make your changes, and submit a pull request. For major changes, please open an issue first to discuss the desired change.

## License

Distributed under the MIT License. See `LICENSE` for more details.
