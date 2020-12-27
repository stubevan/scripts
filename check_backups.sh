#!/usr/bin/env bash

# Check whether directories are ibeing backed up regularly
export LOGFILE=${HOME}/logs/`date +\%Y\%m\%d-\%H\%M\%S`-backup-checks.log
exec > $LOGFILE 2>&1

if [[ $# != 3 ]]; then
	echo "Usage: $0 <source file> <Healthchecks URL> <Max Time>"
	exit 1
fi

dirfile=$1
healthchecks=$2
maxage=$3

if [[ ! -r "${dirfile}" ]]; then
	echo "Source file -> ${dirfile} not accessible"
	exit 1
fi

# Check that age is a number
re='^[0-9]+$'
if [[ ! "$maxage" =~ $re ]] ; then
	echo "Maxage incorrect -> $maxage.  Should be a be a number"
	exit 1
fi

status=0
datenow=$(date -u +%s)

IFS=$'\n'
for dir in $(cat $dirfile | egrep -v '^$|^\#')
do
	#Ensure that the check directory is there
	if [[ ! -d "${dir}" ]]; then
		echo "Target Directory -> ${dir} does not exist"
		status=1
		continue
	fi

	syncdir="${dir}/.syncstatus"

	if [[ ! -d "${syncdir}" ]]; then
		echo "Syndir -> ${syncdir} does not exist"
		status=1
		continue
	fi

	for syncfile in $(ls ${syncdir})
	do
		syncdate=$(cat ${syncdir}/${syncfile} | awk '{print $1}')
		delta=$(echo $(( ($datenow - $syncdate) / 3600 )))

		echo "$dir, $syncfile -> Age $delta hours"
		if (( $delta >= $maxage )); then
			echo "$dir backup from ${syncfile} exceeds threshold of $maxage hours"
			status=1
		fi

	done
done
m=$(cat $LOGFILE)

curl -fsS -m 10 --retry 5 --data-raw "$m" $healthchecks/$status > /dev/null 2>&1

#Clean up logfiles
find $HOME/logs -name \*.log -mtime 14 -exec rm {} \;
exit 0
