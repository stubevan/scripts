#!/usr/bin/env bash
  
# Create the syncstatus files used to monitor backups and synchronisations
# Don't worry about error reporting as if the file doesnt created the final check will fail anyway

IFS=$'\n'
for dir in $(cat $1 | egrep -v '^$|^\#')
do
	#Ensure that the check directory is there
	if [[ ! -d "${dir}" ]]; then
		echo "Target Directory -> ${dir} does not exist"
		continue
	fi

	syncdir="${dir}/.syncstatus"

	if [[ ! -d "${syncdir}" ]]; then
	    	mkdir ${syncdir}
		if [[ ! $? == 0 ]]; then
			echo "Failed to create syncdir -> ${syncdir}"
			continue
		fi
	fi
	# Lay down the egg
	host=$( hostname | awk -F. '{print $1}' )
	eggfile=$(echo "SyncStatus.$(basename ${dir}).$(echo ${host} | awk -F . '{print tolower($1)}').st")
	date -u +%s > ${syncdir}/${eggfile}
done

