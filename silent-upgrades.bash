#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]
	then echo '

This script silently enables automatic upgrades and reboots on Debian or Ubuntu derivatives.

'
    exit 1
fi

if ! [[ -f /etc/debian_version ]]
	then echo This script only works on Debian and Ubuntu derivatives.
	exit 1
fi

if [[ "$EUID" -ne 0 ]]
	then echo Please run this script as root.
	exit 1
fi

# $1 = file to be created/changed/appended
# $2 = setting to be created/changed
# $3 = new value
update_file_setting_to()
{
	# Create the file if it doesn't exist
		# Otherwise, back it up
	# If the setting is commented in the file, uncomment it
	# If the setting exists in the file, edit it
	# If the setting doesn't exist in the file, append it
}

install_unattended_upgrades() {
	echo Installing unattended-upgrades...
	NEEDRESTART_MODE=a apt-get install unattended-upgrades --yes
}

edit_auto_upgrades() {
	echo Enabling unattended upgrades...
	FILE='/etc/apt/apt.conf.d/20auto-upgrades'
	LINE='APT::Periodic::Update-Package-Lists "1"'
	grep -qFs -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
	LINE='APT::Periodic::Unattended-Upgrade "1"'
	grep -qFs -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
}


main() {
	install_unattended_upgrades
	edit_auto_upgrades
}

main "$@"
