#!/bin/bash

#
# Use this script to generate a new SQLite database 'pimember.db' that contains
# all tables needed for PiMember.
#
# If 'pimember.db' already exists it will be backed up as 'pimember.db.<date>.bak'
# to avoid any data loss.
#
# A unix timestamp will be used as format for <date>
#

database=pimember.db

if [ -f "$database" ]; then
    mv "$database" "$database".`date +%s`.bak
fi

sqlite3 "$database" < data/init.sql
