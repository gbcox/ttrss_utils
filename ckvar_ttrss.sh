#!/bin/bash
#
# The purpose of this script is to validate variables needed 
# for various TTRSS utilities. 

if [ -x '../var_ttrss.sh' ]; then
        source ../var_ttrss.sh
else
        echo -e "\e[1;31mThis utility requires you to install and configure 'var_ttrss.sh'\e[0m"
        echo -e "\e[1;31mbefore proceeding.\e[0m"
        exit 99
fi

if [ ! -d "$MAINT_ROOT" ]; then
	kaboom='TRUE'
	echo -e "\e[1;33mMAINT_ROOT=$MAINT_ROOT does not exist.\e[0m"
	echo -e "\e[1;31mPlease correct VARIABLE SECTION.\e[0m"
fi

if [ ! -d "$WEB_ROOT$TTRSS_DIR" ]; then
	kaboom='TRUE'
	echo -e "\e[1;33mTTRSS_DIR=$TTRSS_DIR does not exist.\e[0m"
	echo -e "\e[1;31mPlease correct VARIABLE SECTION.\e[0m"
fi

if [ ! -d "$WEB_ROOT" ]; then
	kaboom='TRUE'
	echo -e "\e[1;33mWEB_ROOT=$WEB_ROOT does not exist.\e[0m"
	echo -e "\e[1;31mPlease correct VARIABLE SECTION.\e[0m"
fi

if [ ! -d "$TTRSS_CONTRIB_GIT" ]; then
	kaboom='TRUE'
	echo -e "\e[1;33mTTRSS_CONTRIB_GIT=$TTRSS_CONTRIB_GIT does not exist.\e[0m"
	echo -e "\e[1;31mPlease correct VARIABLE SECTION.\e[0m"
fi

web_state=$(systemctl show "$WEB_SERVICE.service" --property=LoadState)
web_state=${web_state#*=}
update_state=$(systemctl show "$TTRSS_UPDATE_SERVICE.service" --property=LoadState)
update_state=${update_state#*=}

if [[ ${web_state} = 'error' ]]; then
	kaboom='TRUE'
	echo -e "\e[1;33mWEB_SERVICE=$WEB_SERVICE does not exist.\e[0m"
	echo -e "\e[1;31mPlease correct VARIABLE SECTION.\e[0m"
fi

if [[ ${update_state} = 'error' ]]; then
	kaboom='TRUE'
	echo -e "\e[1;33mTTRSS_UPDATE_SERVICE=$TTRSS_UPDATE_SERVICE does not exist.\e[0m"
	echo -e "\e[1;31mPlease correct VARIABLE SECTION.\e[0m"
fi

sphinx_enabled=$( grep -c "define('SPHINX_ENABLED', true);" "$WEB_ROOT$TTRSS_DIR"'config.php' )
ttrss_dbuser=$( grep "define('DB_USER'," "$WEB_ROOT$TTRSS_DIR"'config.php' )
ttrss_dbname=$( grep "define('DB_NAME'," "$WEB_ROOT$TTRSS_DIR"'config.php' )
ttrss_dbuser=${ttrss_dbuser##*\', \"}
ttrss_dbuser=${ttrss_dbuser%%\"*}
ttrss_dbname=${ttrss_dbname##*\', \"}
ttrss_dbname=${ttrss_dbname%%\"*}

if [[ $sphinx_enabled = '1' ]]; then
	
	sphinx_state=$(systemctl show "$SPHINX_SERVICE.service" --property=LoadState)
	sphinx_state=${sphinx_state#*=}
	
	if [[ ${sphinx_state} = 'error' ]]; then
		kaboom='TRUE'
		echo -e "\e[1;33mSPHINX_SERVICE=$SPHINX_SERVICE does not exist.\e[0m"
		echo -e "\e[1;31mPlease correct VARIABLE SECTION.\e[0m"
	fi
fi

if [[ $kaboom = 'TRUE' ]]; then
	exit 99;
else
	return;
fi


