#!/bin/bash
#
# silent-upgrades.sh - Configure automatic security updates and reboots for Debian/Ubuntu
# Author: johnwbyrd at gmail dot com
# License: https://www.gnu.org/licenses/gpl-3.0.html
# Repository: https://github.com/johnwbyrd/silent-upgrades
# SPDX-License-Identifier: GPL-3.0-or-later
# 
# To install:
#   curl -L -s https://silentupgrades.johnbyrd.com/silent-upgrades.sh | sudo bash
# 
# To uninstall:
#   curl -L -s https://silentupgrades.johnbyrd.com/silent-upgrades.sh | sudo bash -s -- --uninstall

# Configuration
CONFIG_FILE="/etc/apt/apt.conf.d/60silent-upgrades"
VERY_SILENT=false
UNINSTALL=false

# Exit codes
EXIT_SUCCESS=0
EXIT_NOT_ROOT=1
EXIT_NOT_DEBIAN=2
EXIT_PACKAGE_INSTALL_FAILED=3
EXIT_CONFIG_WRITE_FAILED=4
EXIT_UNINSTALL_FAILED=5

# Function to display messages (respects --verysilent)
print_msg() {
    if [ "$VERY_SILENT" = false ]; then
        echo "$1"
    fi
}

# Function to display error messages (always shown)
print_error() {
    echo "ERROR: $1" >&2
}

# Function to check for root privileges and Debian-based system
check_environment() {
    # Check for root privileges
    if [ "$(id -u)" -ne 0 ]; then
        print_error "This script must be run as root."
        exit $EXIT_NOT_ROOT
    fi
    
    # Check for Debian-based system (presence of apt)
    if ! command -v apt-get >/dev/null 2>&1; then
        print_error "This script requires a Debian-based system with apt package manager."
        exit $EXIT_NOT_DEBIAN
    fi
}

# Function to parse command line arguments
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --verysilent)
                VERY_SILENT=true
                ;;
            --uninstall)
                UNINSTALL=true
                ;;
            --help|-h)
                show_help
                exit $EXIT_SUCCESS
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# Function to show help information
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Configures automatic security updates and reboots for Debian/Ubuntu systems.

OPTIONS:
  --uninstall     Remove silent-upgrades configuration
  --verysilent    Suppress all non-error output
  --help, -h      Show this help message

Examples:
  $0                  # Install and configure silent upgrades
  $0 --uninstall      # Remove silent-upgrades configuration
  $0 --verysilent     # Install quietly, only show errors
EOF
}

# Function to install prerequisites
install_prerequisites() {
    print_msg "Checking for unattended-upgrades package..."
    if ! dpkg -l | grep -q unattended-upgrades; then
        print_msg "Installing unattended-upgrades package..."
        NEEDRESTART_MODE=a apt-get install unattended-upgrades --yes
        if [ $? -ne 0 ]; then
            print_error "Failed to install unattended-upgrades package"
            exit $EXIT_PACKAGE_INSTALL_FAILED
        fi
        print_msg "Package installed successfully."
    else
        print_msg "Package already installed."
    fi
}

# Function to create configuration file
create_config() {
    print_msg "Creating configuration file $CONFIG_FILE..."
    cat > "$CONFIG_FILE" << EOF
// silent-upgrades configuration
// Created by silent-upgrades.sh

// Enable automatic updates
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";

// Enable automatic cleanup and reboots
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
EOF

    if [ $? -ne 0 ]; then
        print_error "Failed to write configuration file"
        exit $EXIT_CONFIG_WRITE_FAILED
    fi
    print_msg "Configuration file created successfully."
}

# Function to uninstall configuration
uninstall_config() {
    print_msg "Removing configuration file $CONFIG_FILE..."
    if [ -f "$CONFIG_FILE" ]; then
        rm -f "$CONFIG_FILE"
        if [ $? -ne 0 ]; then
            print_error "Failed to remove configuration file"
            exit $EXIT_UNINSTALL_FAILED
        fi
        print_msg "Configuration file removed successfully."
    else
        print_msg "Configuration file does not exist. Nothing to remove."
    fi
}

# Main function
main() {
    # Parse command line arguments
    parse_args "$@"
    
    # Check for root privileges and Debian-based system
    check_environment
    
    # Banner
    print_msg "Enabling unattended upgrades and reboots..."
    
    # Perform requested action
    if [ "$UNINSTALL" = true ]; then
        print_msg "Uninstalling silent-upgrades configuration..."
        uninstall_config
        print_msg "Uninstallation complete."
    else
        print_msg "Installing silent-upgrades configuration..."
        install_prerequisites
        create_config
        print_msg "Installation complete. Your system will now automatically install security updates and reboot when necessary."
    fi
    
    exit $EXIT_SUCCESS
}

# Run the script
main "$@"
