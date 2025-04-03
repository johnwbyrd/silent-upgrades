# silent-upgrades.sh

- Configure automatic security updates and reboots for Debian, Ubuntu, and derivatives
- Author: johnwbyrd at gmail dot com
- License: https://www.gnu.org/licenses/gpl-3.0.html
- SPDX-License-Identifier: GPL-3.0-or-later

This shell script enables your Debian or Ubuntu or derivative install to automatically download and install recent updates daily, much the same as Windows does.  It also enables automatic reboots, if reboots are necessary to apply recently downloaded system changes.

*Warning!* This shell script may, inadvertently, *silently* put your system into an unbootable state.  This script attempts to automatically download and apply operating system updates, without confirmation, from your operating system provider.  If they make a mistake, and push an update that breaks system in the field, your system will silently break as a result.  Please read the disclaimer of warranty in the associated GPL 3.0 LICENSE file.

In my personal case, I feel that the benefits of having the most recent security bits for my operating systems, is worth the possibility that the distribution developers may inadvertently brick systems in the field.  Weigh these trade-offs carefully before applying this script.

## Installation
 
```
curl -L -s https://silentupgrades.johnbyrd.com | sudo bash
```

# Uninstallation

```
curl -L -s https://silentupgrades.johnbyrd.com | sudo bash -s -- --uninstall
```
