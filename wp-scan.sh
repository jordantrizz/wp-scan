#!/bin/bash
# WordPress Cleaner Script by lmt.ca

SITE_DIR=$1
URL=$2
STORAGE_DIR=$3/$URL
DATE=`date +%F`
SITE_BACKUP=$STORAGE_DIR/$URL-$DATE.tar

flight_check () {
	if ! [ -x "$(command -v wp)" ]; then
		# need fall back for wp to mysql db maybe?
		echo "- wp-cli not installed can't continue"
		exit
	fi
}

help () {
        echo "wp-scan.sh <site directory> <url> <storage directory>"
        exit
}

directories () {
	if [ ! -d $SITE_DIR ]; then
		echo "- Site directory doesn't exist"
		exit
	fi
        if [ ! -d $STORAGE_DIR ]; then
                echo "- Report directory doesn't exist...creating"
                mkdir $STORAGE_DIR
        fi
}

backup () {
        if [ ! -f $SITE_BACKUP ]; then
        	echo "- Backing up site files..."
        	tar -cf $SITE_BACKUP $SITE_DIR
        	#for the future, progress bar
		#tar cf $SITE_BACKUP $SITE_DIR -P | pv -s $(du -sb $SITE_DIR | awk '{print $1}') | gzip > $SITE_BACKUP
        else
        	echo "- Backup already exists for $SITE_BACKUP...exiting"
        	exit
        fi
}

modified_files () {
	echo "- Generating modified-time log..."
	find $SITE_DIR -type f -printf '%TY-%Tm-%Td %TT %p\n' | sort -r > $STORAGE_DIR/$URL-$DATE-modified-time.log
}

active_plugins () {
	echo "- Generating active plugins log..."
	wp --path=$SITE_DIR plugin list > ~/$STORAGE_DIR/$URL-$DATE-wp-plugin-list.log
}

if [ -z $SITE_DIR ]; then
        help
elif [ -z $URL ]; then
        help
elif [ -z $STORAGE_DIR ]; then
        help
fi

flight_check
directories
backup
modified_files
active_plugins