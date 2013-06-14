#!/bin/bash
# Created for use with Fedora.  If you aren't using Fedora, you may need
# to make adjustments
#
# This script will update your copy of the Tiny-Tiny-RSS and Tiny-Tiny-RSS-Contrib
# repositories.  Contrib plugins will then be copied to your ttrss/plugins directory
#
# The script assumes you are running an update-daemon.  Actions for the Sphinx search
# engine will be taken if it has been activated
#
# If you install cfg_o_matic.sh in the same directory, your config.php file
# will be automatically updated.  Please read cfg_o_matic.sh for more information
#
# All displayed messages will also be saved in a logfile
# Logfiles will be kept in $WEB_ROOT$TTRSS_DIR for 14 days
#
# You must also have issued git clone before running this script:
# git clone https://github.com/gothfox/Tiny-Tiny-RSS.git $WEB_ROOT$TTRSS_DIR
# git clone https://github.com/gothfox/Tiny-Tiny-RSS-Contrib.git $TTRSS_CONTRIB_GIT
#
# Additional information can be found here:
# http://tt-rss.org/forum/viewtopic.php?f=1&t=1697
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

owner_group=$( stat -c %U':'%G $TTRSS_CONTRIB_GIT )
git_logfile="$WEB_ROOT$TTRSS_DIR"'ttrss_git_log_'$(date '+%Y%j_%H%M')
INPUT1="$WEB_ROOT$TTRSS_DIR"'config.php-dist'
INPUT2="$WEB_ROOT$TTRSS_DIR"'config.php'
INPUT3="$WEB_ROOT$TTRSS_DIR"'config.php-dist_tmp'
OUTPUT="$WEB_ROOT$TTRSS_DIR"'config.php_tmp'
HOST=$( uname -n )

if [ ! -d "${TTRSS_CONTRIB_GIT}.git" ]; then
    echo "${TTRSS_CONTRIB_GIT} is not a valid git directory."
    exit;
elif [ ! -d "${WEB_ROOT}${TTRSS_DIR}.git" ]; then
    echo "${WEB_ROOT}${TTRSS_DIR} is not a valid git directory."
    exit;
fi

systemctl stop "${WEB_SERVICE}.service";
systemctl stop "${TTRSS_UPDATE_SERVICE}.service";

if [[ ${sphinx_enabled} = '1' ]]; then
	systemctl stop "${SPHINX_SERVICE}.service";
fi

cp "$INPUT1" "$INPUT3"

ttrss_git=$( git --git-dir="${WEB_ROOT}${TTRSS_DIR}.git" --work-tree="${WEB_ROOT}${TTRSS_DIR}" pull 2>&1 );
config_git=$( git --git-dir="${TTRSS_CONTRIB_GIT}.git" --work-tree="${TTRSS_CONTRIB_GIT}" pull 2>&1 );
cp -au "${TTRSS_CONTRIB_GIT}plugins/"* "${WEB_ROOT}${TTRSS_DIR}plugins/";
chown -R "${WEB_SERVICE}:${WEB_SERVICE}" "${WEB_ROOT}";
chown -R "$owner_group" "$TTRSS_CONTRIB_GIT"
chmod -R '777' "${WEB_ROOT}${TTRSS_DIR}cache"
chmod -R '777' "${WEB_ROOT}${TTRSS_DIR}feed-icons"
chmod -R '777' "${WEB_ROOT}${TTRSS_DIR}lock"


echo -e "\e[1;32mTTRSS GIT PULL RESULTS\e[0m" | tee -a $git_logfile
echo -e "\e[1;33m$ttrss_git\e[0m" | tee -a $git_logfile
echo -e "\e[1;32mTTRSS CONTRIB GIT PULL RESULTS\e[0m" | tee -a $git_logfile
echo -e "\e[1;33m$config_git\e[0m" | tee -a $git_logfile

if [[ "$ttrss_git" = *config.php-dist* ]]; then
	if [ -x 'cfg_o_matic.sh' ]; then
		echo -e "\e[1;31mConfig change.  Calling cfg_o_matic.\e[0m" | tee -a $git_logfile
		source cfg_o_matic.sh
	else
		echo -e "\e[1;31mConfig change.  You will need to manually check your config.php\e[0m" | tee -a $git_logfile
		echo -e "\e[1;31mIf you make changes, services will need to be manually restarted.\e[0m" | tee -a $git_logfile
		echo -e "\e[1;31mConsider installing cfg_o_matic.sh\e[0m" | tee -a $git_logfile
	fi
fi

if [[ "$ttrss_git" = *schema* ]]; then
	echo -e "\e[1;31mSchema change.  You will be prompted to change when you login.\e[0m" | tee -a $git_logfile
	echo -e "\e[1;31mAfter updating the schema, you will need to manually start the TTRSS_UPDATE_SERVICE.\e[0m" | tee -a $git_logfile
	echo -e "\e[1;31mIf using Sphinx, you need to recreate the Sphinx full-text index,\e[0m" | tee -a $git_logfile
	echo -e "\e[1;31mthen manually start the SPHINX_SERVICE.\e[0m" | tee -a $git_logfile
	systemctl start "${WEB_SERVICE}.service";
else
	systemctl start "${WEB_SERVICE}.service";
	systemctl start "${TTRSS_UPDATE_SERVICE}.service";
	if [[ ${sphinx_enabled} = '1' ]]; then
		systemctl start "${SPHINX_SERVICE}.service";
	fi
fi

find $WEB_ROOT$TTRSS_DIR'ttrss_git_log_'* -maxdepth 1 -type f -mtime +14 -delete
rm "$INPUT3"
exit;
