#!/bin/bash
#
# The purpose of this script is to set variables needed 
# for various TTRSS utilities. 
# 
# IMPORTANT:  VALIDATE and modify as appropriate the first six uncommented lines.  These
# will set the variables for your local installation.

# >>>>>> START USER MODIFIED VARIABLE SECTION <<<<<<

TTRSS_DIR='rss/';					# VALIDATE - TTRSS Directory Name
TTRSS_CONTRIB_GIT='/home/xxxxx/ttrss_contrib/';		# VALIDATE - CONTRIB git clone location
WEB_ROOT='/var/www/html/';				# VALIDATE - System default for Fedora
WEB_SERVICE='nginx';					# VALIDATE - Either apache or nginx
TTRSS_UPDATE_SERVICE='rss-update';			# VALIDATE - What you named the update service
SPHINX_SERVICE='searchd';				# VALIDATE - System default for Sphinx on Fedora

# >>>>>> END USER MODIFIED VARIABLE SECTION <<<

return;

