#!/bin/sh

#  drupal_update.sh
#  Created by Arun Natarajan on 12/31/12.
#  This script will automate the drupal update process and support restoring an old data version of drupal, if the backup files exist.
#  Dont be panic, please modify the variables section of this script to match with your setup.
#  Use this script at your own risk :)
#  This script assumes that you dont have any other product installed on the document root, otherwise it may affect the restore process.

# Please modify these variables to match with your setup
BACKUP_PATH=/home/foo/backups
SOURCE_PATH=/home/foo/sources
DRUPAL_PATH=/home/foo/public_html
MYSQL_PATH=/usr/local/bin/mysql
MYSQLDUMP_PATH=/usr/bin/mysqldump
MYSQL_USER=<mysql_user>
MYSQL_PASSWORD=<mysql_password>
MYSQL_DATABASE=<mysql_database_name>
CORE_FILES="LICENSE.txt MAINTAINERS.txt misc/ modules/ profiles/ README.txt scripts/ themes/ update.php UPGRADE.txt  xmlrpc.php index.php install.php authorize.php CHANGELOG.txt COPYRIGHT.txt cron.php INSTALL.mysql.txt INSTALL.pgsql.txt INSTALL.sqlite.txt robots.txt INSTALL.txt web.config"

# Create backup and source directories
mkdir -p $BACKUP_PATH $SOURCE_PATH >/dev/null 2>&1

# Menu
echo -n " Please enter your choice:
 1. Upgrade drupal
 2. Restore an old installation from backup
 3. Exit
"
read choice

# 1. Upgrade drupal
case $choice in 
 1)
  echo "Please enter the new drupal version (eg: 7.15) : "
  read version
  drupal_version="drupal-${version}"
  drupal_package="${drupal_version}.tar.gz"
  drupal_url="http://ftp.drupal.org/files/projects/${drupal_package}"
  time="$(date +"%d-%m-%Y-%H%M")"

  # Download the drupal
  if curl --output /dev/null --silent --head --fail "$drupal_url"; then
   echo "Downloading $drupal_version"
   cd $SOURCE_PATH; curl -s -O $drupal_url; tar xzf $drupal_package
   echo "Done.."
  else
   echo "This drupal version not exiting: $drupal_version"
   exit 1
  fi

  # Make a backup of current website
  mkdir -p $BACKUP_PATH/$time
  cp -prf $DRUPAL_PATH/* $BACKUP_PATH/$time/
  echo "Current site backup is created: $BACKUP_PATH/$time"

  # Database backup
  $MYSQLDUMP_PATH -u $MYSQL_USER --password="$MYSQL_PASSWORD" $MYSQL_DATABASE > $BACKUP_PATH/$MYSQL_DATABASE_$time.sql
  echo "Database backup created: $BACKUP_PATH/$MYSQL_DATABASE_$time.sql"

  # Push the site to maintance mode
  $MYSQL_PATH -u $MYSQL_USER --password="$MYSQL_PASSWORD" $MYSQL_DATABASE -e "UPDATE variable SET value='s:1:\"1\"' WHERE name = 'site_offline'"
  echo "Site is in maintanence mode now"

  # Update drupal
  cd $DRUPAL_PATH

  # Remove drupal core files
  rm -rf $CORE_FILES
  echo "Removed all drupal core files from destination"

  # Copy the new drupal core files
  cp -R $SOURCE_PATH/$drupal_version/* .
  echo "Copied the new version contents"

  # Site back active
  $MYSQL_PATH -u $MYSQL_USER --password="$MYSQL_PASSWORD" $MYSQL_DATABASE -e "UPDATE variable SET value='s:1:\"0\"' WHERE name = 'site_offline'"
  echo "Drupal upgraded to $drupal_version"
  echo "Site is active again, but please update your database, please visit http://<yourwebsite>/update.php to finalize the process"

  # Remove source files
  rm -rf $SOURCE_PATH/*
  echo "Removed the source files"
;;

# 2. Restore drupal
 2)
  # List backups
  echo "List of available backups"
  ls  $BACKUP_PATH | grep -v "sql"
  echo "Please enter the backup file name to restore: (eg: 08-01-2013-0753): "
  read RESTORE_FILE

  # Push the site to maintance mode
  $MYSQL_PATH -u $MYSQL_USER --password="$MYSQL_PASSWORD" $MYSQL_DATABASE -e "UPDATE variable SET value='s:1:\"1\"' WHERE name = 'site_offline'"
  echo "Site is offline now"
  rm -rf $DRUPAL_PATH/$CORE_FILES
  echo "Removed production files"
  cp -R $BACKUP_PATH/$RESTORE_FILE/* $DRUPAL_PATH/
  echo "Restored the filesystem backup $backup_file"

  # Restore database
  $MYSQL_PATH -u $MYSQL_USER --password="$MYSQL_PASSWORD" $MYSQL_DATABASE < $BACKUP_PATH/$RESTORE_FILE.sql
  echo "Restored the database"

  # Site back active
  $MYSQL_PATH -u $MYSQL_USER --password="$MYSQL_PASSWORD" $MYSQL_DATABASE -e "UPDATE variable SET value='s:1:\"0\"' WHERE name = 'site_offline'"
  echo "Site is restored"
;;

# 3. Exit
 3)
  echo "nothing done"
  exit 0
;;

# Anyting else
 *)
  echo
  echo " Usage:"
  echo " Please replace the variable to matchin with your installation"
  echo " Use the correct drupal version"
  echo " "
  exit 0
;;
esac

