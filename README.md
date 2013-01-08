upgrade-restore-drupal7
=======================

Shell script to upgrade and restore Drupal 7 website

This script will take care of the necessary actions required for upgrading drupal to higher versions.

USAGE
=====
- Copy the script to your webserver.
- Edit the script and change the variables to match with your setup
- Give execute privilege to the owner of the script (chmod u+x upgrade-restore-drupal7.sh)
- Execute the script ./upgrade-restore-drupal7.sh

UPGRADE
======
$ ./upgrade-restore-drupal7.sh
 Please enter your choice:
 1. Update drupal
 2. Restore an old installation from backup
 3. Exit
1
Please enter the new drupal version (eg: 7.15) : 
7.18
Downloading drupal-7.18
Done...
Current site backup is created: /home/foo/backups/08-01-2013-0938
Database backup created: /home/foo/backups/08-01-2013-0938.sql
Site is in maintanence mode now
Removed all drupal core files from destination
Copied the new version contents
Drupal updated to drupal-7.18
Site is active again, but please update your database, please visit http://<yourwebsite>/update.php to finalize the process
Removed the source files

RESTORE
=======
$ ./upgrade-restore-drupal7.sh
Please enter your choice:
 1. Update drupal
 2. Restore an old installation from backup
 3. Exit
2
List of available backups
08-01-2013-0753
08-01-2013-0758
08-01-2013-0804
08-01-2013-0841
08-01-2013-0849
08-01-2013-0858
08-01-2013-0900
08-01-2013-0904
08-01-2013-0905
08-01-2013-0938
Please enter the backup file name to restore: (eg: 08-01-2013-0753): 
08-01-2013-0905
Site is offline now
Removed production files
Restored the filesystem backup 
Restored the database
Site is restored

Arun Natarajan S, arun@arunns.com
