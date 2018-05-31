#!/bin/bash

# ualbanyVPNDown.sh

# NOTE: The following script was copied 
#       from http://www.socsci.uci.edu/~jstern/uci_vpn_ubuntu/ucivpndown.txt
#       and modified for use with UAlbany's VPN -- PJT 2018-05-30

# where you want any output of status / errors to go
# (this should match same var in the ucivpnup script)
# (required)
OCLOG="/tmp/ualbanyVPN.oclog"

# ----------------------------------------------------------
# you should not have to change or edit anything below here
# ----------------------------------------------------------

echo "$(date): Script ${0} starting." >> "${OCLOG}" 2>&1

# Shut down openconnect process if one (or more) exists

# find the pid(s) of any openconnect process(es)
pidofoc="$(pidof openconnect)"
# use those pids to kill them
if [ "$pidofoc" != "" ]; then
	echo "$(date): Stopping openconnect PID ${pidofoc}." >> "${OCLOG}" 2>&1
	sudo kill -9 "${pidofoc}" >> "${OCLOG}" 2>&1
else
	echo "$(date): No openconnect found. (That's okay.) Continuing." >> "${OCLOG}" 2>&1
fi

# Close down the tun1 openvpn tunnel

if /sbin/ifconfig | grep -c '^tun1'; then
	echo "$(date): Shutting down openvpn tunnel tun1" >> "${OCLOG}" 2>&1
	sudo ifconfig tun1 down >> "${OCLOG}" 2>&1
else
	echo "$(date): No tun1 found. Good!" >> "${OCLOG}" 2>&1
fi

echo "$(date): ${0} script ending successfully." >> "${OCLOG}" 2>&1
