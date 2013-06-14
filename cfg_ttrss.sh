#!/bin/bash
#
# This version is intended only for the normally released versions
#
# Do not use if you are using the trunk via git, instead use git_ttrss.sh
#
# FIRST TIME USAGE:
# Run this utility BEFORE and AFTER the upgrade.  This will allow the utility
# to create a "before-upgrade" image of "config.php-dist" to use for 
# comparison purposes.  If you have already upgraded, you won't be able to 
# take advantage of this check for the first time run - however, subsequent
# runs will be able to do this extra comparison.  DO NOT delete or change
# the "config.php-dist_cfg_ttrss" file this utility creates
#
# IMPORTANT:  You must customize the variables located in the
# uncommented lines of var_ttrss.sh before running this utility

if [ -x 'ckvar_ttrss.sh' ]; then
	source ckvar_ttrss.sh
else
	echo -e "\e[1;31mThis utility requires you to install and configure 'ckvar_ttrss.sh'\e[0m"
	echo -e "\e[1;31mbefore proceeding.\e[0m"
        exit 99
fi

git_logfile="$WEB_ROOT$TTRSS_DIR"'ttrss_cfg_log_'$(date '+%Y%j_%H%M')
INPUT1="$WEB_ROOT$TTRSS_DIR"'config.php-dist'
INPUT2="$WEB_ROOT$TTRSS_DIR"'config.php'
INPUT3="$WEB_ROOT$TTRSS_DIR"'config.php-dist_cfg_ttrss'
OUTPUT="$WEB_ROOT$TTRSS_DIR"'config.php_tmp'
HOST=$( uname -n )

if [ ! -s $INPUT3 ]; then
	cp "$INPUT1" "$INPUT3"
	echo -e "\e[1;31mCreating $INPUT3.  Do not delete.\e[0m" | tee -a $git_logfile
fi

if [ -x 'cfg_o_matic.sh' ]; then
    echo -e "\e[1;31mCalling cfg_o_matic.\e[0m" | tee -a $git_logfile
    source cfg_o_matic.sh
else
    echo -e "\e[1;31mThis utility requires cfg_o_matic.sh - please install.\e[0m" | tee -a $git_logfile
fi

cp "$INPUT1" "$INPUT3"
exit
