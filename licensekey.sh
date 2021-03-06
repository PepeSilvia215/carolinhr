#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $script_dir # now we are safe
base_dir="$(dirname $script_dir)"
if [[ ! -f licensekey ]]
then
	echo "changeme" > licensekey
fi
sv_licenseKey="$(cat licensekey)"
set_key=true
if [[ ! $sv_licenseKey =~ ^[a-zA-Z0-9]{32}$ ]]
then
	echo -e "The license key is not set up yet.\n"
else
	echo -e "The license key is currently set to:\n"
	echo -e "$sv_licenseKey\n"
	set_key=false
fi
#echo ""
if [[ $set_key == true ]] 
then
	read -p "Would you like to set the license key now (Y/n?)" -n 1 -r
else
	read -p "Would you like to change the license key now (Y/n)?" -n 1 -r
fi
echo ""
echo ""
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]
then
	read -p "Go to https://keymaster.fivem.net and sign in or register an account. Then register a license key for your server. When you are done copy it to your clipboard, click in this terminal window and paste it in. Most terminals require you to pres Control Shift V.`echo $'\n> '`" -n 32 -r
	sv_licenseKey=$REPLY
	echo ""
	echo $sv_licenseKey > licensekey
	
	cd $base_dir
	if [[ -f server.cfg ]] 
	then
		if grep -q sv_licenseKey "server.cfg";
		then
			sed -i '/sv_licenseKey/d' server.cfg
		fi
		echo -e "Updating server config"

		if [[ $(tail -c 1 server.cfg) != "" ]]
		then
			echo -e "\nsv_licenseKey $sv_licenseKey" >> server.cfg
		else
			echo -e "sv_licenseKey $sv_licenseKey" >> server.cfg
		fi

	else
		echo -e "Server config was not changed, doesn't exist\n"
	fi
	cd carolinhr
		echo -e "License key updated!"
fi
