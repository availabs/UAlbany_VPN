#!/bin/bash

# ualbanyVPNUp.sh


# NOTE: The following script was copied 
#       from http://www.socsci.uci.edu/~jstern/uci_vpn_ubuntu/ucivpnup.txt
#       and modified for use with UAlbany's VPN -- PJT 2018-05-30

# Openconnect command-line script for connecting to UCI's VPN servers
# from Debian-Ubuntu-derived Linux distro's.  More info at
#    http://www.socsci.uci.edu/~jstern/uci_vpn_ubuntu/ubuntu-openconnect-uci-instructions.html
#
# This script adapted from David Schneider's great page on github at
#    https://github.com/dnschneid/crouton/wiki/Using-Cisco-AnyConnect-VPN-with-openconnect
# and with help from OIT's Linux OpenConnect instructions at
#    http://www.oit.uci.edu/kb/vpn-linux/
#
# Jeff Stern 2015-10-21
#
# Later, spurred on by a request from UC Berkeley compatriot Leo Simon
# to make the script more fully automated, I later split this into 2
# scripts so they can be automated and used inside other bash scripts
# if necessary.  -JS 2017-08-28
#

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

# get the VPNUSER from the convenience script
# At UAlbany, we use your NetID (all lower-case) for this
# (required)
# source ./vpnuser
VPNUSER='Your NetID'

# VPNGRP
# (required)
VPNGRP="webvpn"

# your VPN password. At UAlbany we use our NetID password.  Storing it
# in plain text here in this file is insecure, though. It is better to
# put your password into a $HOME/.authinfo file and use a 2nd script
# to read that password and echo it.  If I find the time, I will add
# that functionality to this script and the instructions. At least
# this will suffice for now, 'just to get things going'.
#
# On the other hand, if you leave PW blank, or empty string, the
# script will prompt you for it.
# (optional)
# PW="mypass"
PW=""

# where you want any output of status / errors to go
# (this should match same var in the ucivpndown script)
# (required)
OCLOG="/tmp/ualbanyVPN.oclog"

# ----------------------------------------------------------
# you should not have to change or edit anything below here
# ----------------------------------------------------------

# where you will be connecting to for your VPN services
# (required)
VPNURL=https://vpn.albany.edu

# this should be universal for most Debian/Ubuntu derived Linux distro's
# (required)
VPNSCRIPT=/usr/share/vpnc-scripts/vpnc-script

# timestamp
echo "$(date): Script ${0} starting." >> "${OCLOG}" 2>&1

# Make an openvpn tunnel (interface), and if successful, use it to
# connect to our Cisco server.
if ! /sbin/ifconfig | grep -c '^tun1'; then
  echo "$(date): Creating tun1 openvpn interface." >> "${OCLOG}" 2>&1
	sudo openvpn --mktun --dev tun1 >> "${OCLOG}" 2>&1
	# check successful, else quit
	if [ $? -eq 0 ]; then
		echo "$(date): tun1 openvpn interface created successfully." >> "${OCLOG}" 2>&1
	else
		echo "$(date): Problems creating tun1 openvpn interface. Exiting 1." >> "${OCLOG}" 2>&1
		exit 1
	fi
else
	echo "$(date): tun1 openvpn interface already exits." >> "${OCLOG}" 2>&1
fi

# Turn on tun1 openvpn interface. If it is already on, it won't hurt
# anything.
echo "$(date): Turning tun1 on." >> "${OCLOG}" 2>&1
sudo ifconfig tun1 up >> "${OCLOG}" 2>&1
# check successful, else quit
if [ $? -eq 0 ]; then
	echo "$(date): tun1 on." >> "${OCLOG}" 2>&1
else
	echo "$(date): Problems turning tun1 on. (This may leave tun1 existing though.) Exiting 1." >> "${OCLOG}" 2>&1
	exit 1
fi

# Check for any pre-existing openconnect connections. If one exists
# already, we will not create a new one.
pidofoc="$(pidof openconnect)"
echo "$(date): Running openconnect." >> "${OCLOG}" 2>&1
if [ "$pidofoc" == "" ]; then
	if [ -z "$PW" ]; then
		# password var was not set above. User will have to be queried
		# and type it in manually at keyboard
		sudo openconnect -b -s "${VPNSCRIPT}" \
						--user="${VPNUSER}" \
						--authgroup="${VPNGRP}" \
						--interface="tun1" \
						"${VPNURL}"
	else
		# password var was set above. Pass it in via stdin
		echo "${PW}" | sudo openconnect -b -s "${VPNSCRIPT}" \
							--user="${VPNUSER}" \
							--passwd-on-stdin \
							--authgroup="${VPNGRP}" \
							--interface="tun1" \
							"${VPNURL}" >> "${OCLOG}" 2>&1
	fi
else
	echo "$(date): Not initiating an openconnect session because one appears to already exist: PID=${pidofoc}" >> "${OCLOG}" 2>&1
fi

echo "$(date): ${0} script ending successfully." >> "${OCLOG}" 2>&1

popd >/dev/null
