#!/bin/bash
# This script is not intended to be run standalone.  It will be called
# from other utilities.
#
# This script will merge changes into your config.php from config.php-dist
# The assumption is that config.php-dist changes are authoratative
# This means that if something changes in config.php-dist those changes
# will be merged into your config.php
# Changes made to your config.php will be preserved only if they are made to
# a define statement AND that define statement has not been changed in config.php-dist
# from the time it was originally cloned into your config.php
# If a define has been changed, it will replace whatever you had in your config.php
# The assumption being this is something which requires manual intervention
#
# Your config.php will be built based upon four conditions:
# TTRSS DEFAULT:  This statement matches what is in config.php-dist
# $HOST OVERRIDE:  You have customized the entry from config.php-dist
# TTRSS CHANGE:  The dist copy has changed on a modified record, you need to manually redo 
# NEW OPTION FOUND: A new option has been added during this update 
# 
# Previous versions of your config.php will be kept for 14 days

[ ! -s $INPUT1 ] && { echo "$INPUT1 file not found"; exit 99; }

while IFS= read -r data_string

do
	if [[ "${data_string:1:6}" = 'define' ]]; then
		dataopt=${data_string%%,*}
		dataopt=${dataopt#"${dataopt%%[![:space:]]*}"}
		if [[ ${dataopt:9:14} = 'CONFIG_VERSION' ]]; then
                	echo "$data_string" >> $OUTPUT;
		else
			matchvar=$( grep  "$dataopt" "$INPUT2" )
			grep_rc=$?
			defvalid=${matchvar%%,*}
			defvalid=${defvalid#"${defvalid%%[![:space:]]*}"}
			if [[ "${grep_rc}" = '0' ]]; then
				if [[ "${matchvar}" != "${data_string}" ]]; then
					distvar=$( grep "$dataopt" "$INPUT3" ) 
					if [[ "${distvar}" != "${data_string}" ]] | [[ "${defvalid:0:6}" != 'define' ]]; then
						echo -e "\e[1;31mTTRSS CHANGE ===> $data_string\e[0m" | tee -a $git_logfile
                                                echo "$data_string" >> $OUTPUT;
                                        else
						matchvar=${matchvar#"${matchvar%%[![:space:]]*}"}
						echo -e "\e[1;33m$HOST override ===> \t$matchvar\e[0m" | tee -a $git_logfile
						echo -e "\t$matchvar" >> $OUTPUT;
					fi
				else
					echo -e "\e[1;32mTTRSS Default  ===> $data_string\e[0m" | tee -a $git_logfile
					echo "$matchvar" >> $OUTPUT;
				fi
			else
				echo -e "\e[1;34mNew option found ===> $data_string\e[0m" | tee -a $git_logfile
				echo "$data_string" >> $OUTPUT;
			fi
		fi
	else
		echo "$data_string" >> $OUTPUT
	fi
done < $INPUT1
mv "$INPUT2" "$INPUT2"'_archive_'"$(date '+%Y%j_%H%M')"
mv "$OUTPUT" "$INPUT2"
find $INPUT2'_archive_'* -maxdepth 1 -type f -mtime +14 -delete
return
