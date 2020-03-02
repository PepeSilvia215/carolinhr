#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $script_dir # now we are safe
if [[ ! -f mysql-password ]]
then
		echo -e "No mysql-password file, aborting!\n"
		exit 1
fi
if [[ ! -f mysql-user ]]
then
		echo -e "No mysql-user file, aborting!\n"
		exit 1
fi
resources="$(cat resources.json | jq -r '.resources[]')"
echo -e "About to install the following resources:"
echo -e "$(echo $resources | tr " " "\n")"
echo ""
echo -e "WARNING! This script installs all the mods configured in resources.json into the server data resources folder. It also injects the appropriate sql files into the database. You must have mysql installed and running with  user and passowrd stored in a one line file in this dir named mysql-user and mysql-password respectively. You can run nuke-redem-database.sh if the database is already initialized. This is super beta\n"
read -p "Are you sure? You must type INIT. " -n 4 -r
echo ""
if [[ ! $REPLY == "INIT" ]]
then
	exit 1
fi
if [[ ! -d ../../server-data/resources ]]
then
	echo -e "Server has not been initialized yet, aborting!\n"
	exit 1
else
	if [[ ! -d ../../server-data/resources/\[carolinhr\] ]]
	then
		echo -e "making [carolinhr] resource folder...\n"
		mkdir ../../server-data/resources/\[carolinhr\]
	fi
fi
if [[ ! -f ../../resources.cfg ]]
then
	echo -e "set es_enableCustomData 1\nset mysql_connection_string \"server=localhost;uid=$(cat mysql-user);password=$(cat mysql-password);database=redemrp\"\n" > ../../resources.cfg
fi
cd ../../server-data/resources/\[carolinhr\]
for resource in $resources
do
	if [[ -d $resource ]]
	then
		echo -e "$resource is already installed, double check the resources folder, this script should really only be run after the server has been initialized."
		exit 1
	fi
done
for resource in $resources
do
	echo "Installing $resource..."
	repo="$(cat $script_dir/resources.json | jq -r --arg resource "$resource" '.repos[] | .[$resource]')"
	echo "Fetching from $repo..."
	mkdir $resource
	cd $resource
	git clone $repo
	cd ../
	echo ""
done
if [[ -f ../../resources.cfg ]]
then
	rm ../../resources.cfg
fi
echo "Injectin'..."
injection_dirs="$(cat $script_dir/resources.json | jq -r '.injections[] | keys[]')"
for injection_resource in $injection_dirs
do
	cd $injection_resource
	injection="$(cat $script_dir/resources.json | jq -r --arg injection_dir "$injection_dir" '.injections[] | .[$injection_dir]')"
	echo "Doin $injection_dir injectin $injection..."
	mysql --user="$(cat $script_dir/mysql-user)" --password="$(cat $script_dir/mysql-password)" < $injection
	cd ../
done
