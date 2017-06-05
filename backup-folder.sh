#!/bin/bash
#Purpose = Backup of Logs OpenVPN
#Created on 05-06-2017
#Author = Tung Pham
#Version 1.0
# What to backup. 
backup_files="/etc/openvpn/log"

# Where to backup to.
dest="/home/ubuntu/openvpn-logs"

# Create archive filename.
day=$(date +%b-%d-%y)
archive_file="$day.tgz"

# Print start status message.
echo "Backing up $backup_files to $dest/$archive_file"
date
echo

# Backup the files using tar.
tar czf $dest/$archive_file $backup_files

# Print end status message.
echo
echo "Backup finished"
date

# Long listing of files in $dest to check file sizes.
ls -lh $dest

find /home/ubuntu/openvpn-logs/$day.tgz -mtime +7 -exec rm {} \;
