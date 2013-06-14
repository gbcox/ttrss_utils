#!/bin/bash
# This utility will create a POSTGRESQL backup.  It is intended to be run from crontab
# but can also be invoked manually
#
# IMPORTANT:  You must customize the variables located in the
# uncommented lines of var_ttrss.sh before running this utility

if [ -x 'ckvar_ttrss.sh' ]; then
	source ckvar_ttrss.sh
else
	echo -e "\e[1;31mThis utility requires you to install and configure 'var_ttrss.sh'\e[0m"
	echo -e "\e[1;31mbefore proceeding.\e[0m"
	exit 99
fi

pg_dump -U "$ttrss_dbuser" "$ttrss_dbname" | xz > "$MAINT_ROOT"db_backup/ttrss_$(date '+%Y%j_%H%M').sql.xz
find "$MAINT_ROOT"db_backup/ttrss_*.xz -maxdepth 1 -type f -mtime +14 -delete
exit
