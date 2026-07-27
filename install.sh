#!/bin/bash

# Initialize the output colors, honoring a terminal stream and the NO_COLOR convention
if [ -t 1 ] && [ -z "${NO_COLOR}" ]; then
    BOLD=$(printf '\033[1m')
    GREEN=$(printf '\033[32m')
    GRAY=$(printf '\033[90m')
    RED=$(printf '\033[31m')
    RESET=$(printf '\033[0m')
else
    BOLD=""
    GREEN=""
    GRAY=""
    RED=""
    RESET=""
fi


# Check the root privileges
if [ "$(whoami)" != "root" ]; then
  echo "${BOLD}${RED}Requires root privileges${RESET}"

  exit 1
fi


# Initialize the host OS variable
OS=$(uname -s)

case "$OS" in
    Linux)
        OS="linux"
        ;;

    Darwin)
        OS="darwin"
        ;;

    *)
        echo "${BOLD}${RED}Unsupported OS: $OS${RESET}"
        echo "${RED}Supported OS are Linux and MacOS${RESET}"

        exit 1
        ;;
esac


# Initialize the host architecture variable
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;

    aarch64)
        ARCH="arm64"
        ;;

    arm64)
        ARCH="arm64"
        ;;

    *)
        echo "${BOLD}${RED}Unsupported architecture: $ARCH${RESET}"
        echo "${RED}Supported architectures are x86_64, aarch64, and arm64${RESET}"

        exit 1
        ;;
esac


# Install the CLI
echo "Installing dxflow ..."

# Define a temporary directory for download
TEMP_DIR=$(mktemp -d)

# Retrieve the latest version tag from GitHub without using jq
# Releases (binaries) are published to the dxflow-ai/community repo by engine CI
LATEST_URL=$(curl -s "https://api.github.com/repos/dxflow-ai/community/releases/latest" | grep -m 1 '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')

if [ -z "$LATEST_URL" ]; then
    echo "${BOLD}${RED}Error: Unable to retrieve the latest version tag from GitHub.${RESET}"

    exit 1
fi

echo "${GRAY}Latest release tag: ${LATEST_URL}${RESET}"

VERSION=$(basename "${LATEST_URL}")
CLEAN_VERSION=${VERSION#v}

echo "Downloading dxflow version ${CLEAN_VERSION} for ${OS} ${ARCH}..."

# Archive name matches the engine .goreleaser.yaml archive name_template
CLI_ARCHIVE="${TEMP_DIR}/dxflow_${OS}_${ARCH}.tar.gz"
GITHUB_URL="https://github.com/dxflow-ai/community/releases/download/${VERSION}/dxflow_${OS}_${ARCH}.tar.gz"

echo "${GRAY}Downloading from: ${GITHUB_URL}${RESET}"

# Download the CLI archive
wget -qO "${CLI_ARCHIVE}" "${GITHUB_URL}"

if [ $? -ne 0 ]; then
    echo "${BOLD}${RED}Failed to download dxflow from GitHub${RESET}"
    echo "${RED}Please check your internet connection and try again${RESET}"

    exit 1
fi


# Extract the CLI to /usr/local/bin
tar -xzf "${CLI_ARCHIVE}" -C /usr/local/bin

if [ $? -ne 0 ]; then
    echo "${BOLD}${RED}Failed to extract dxflow archive${RESET}"
    echo "${RED}Please check the archive and try again${RESET}"

    exit 1
fi


# Clean up the temporary directory
rm -rf "${TEMP_DIR}"


# Make the CLI executable
chmod +x "/usr/local/bin/dxflow"


# Done CLI installation
echo "${BOLD}${GREEN}dxflow installed successfully${RESET}"
echo "${GRAY}You can verify the CLI installation by running: 'dxflow --version'${RESET}"
