#!/bin/bash

#
# Use this script to add some sample data to your PiMember database.
#

database=pimember.db

if [ ! -f "$database" ]; then
    echo "No database found!";
    exit 1;
fi

sqlite3 "$database" < data/samples.sql
