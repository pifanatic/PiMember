#!/usr/bin/env perl
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

if ($#ARGV < 0) {
    print "Please provide a database name!\n";
    exit 1;
}

my $dbname = $ARGV[0];

make_schema_at(
    'PiMember::Schema',
    {
        debug => 1,
        dump_directory => './lib',
    },
    [
        "dbi:SQLite:$dbname"
    ],
);
