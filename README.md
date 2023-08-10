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
  - [Example](#example)
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
- **configuration**: Launch the configuration wizard.
- **completion**: Generate a completion script for bash or zsh.
- **help**: Display the help message.

## Setup

### Config File

To configure the proxy, create a `proxy.conf` file in your `$HOME` directory or specify its location using the `PROXY_SWITCHER_CONFIG` environment variable.

The configuration should contain the following two variables:

```text
HTTP_PROXY=http://proxy.company.com:PORT
HTTPS_PROXY=http://proxy.company.com:PORT
```

As an alternative, run the script with the `configuration` command and follow the on-screen instructions.

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

## Example

```bash
# Set the proxy:
proxy on

# Unset the proxy:
proxy off

# Check the proxy status:
proxy status

# Launch the configuration wizard:
proxy configuration
```

## Contributing

Contributions are welcome! Fork the repository, make your changes, and submit a pull request. For major changes, please open an issue first to discuss the desired change.

## License

Distributed under the MIT License. See `LICENSE` for more details.
