#!/usr/bin/env perl

use lib "lib/";
use PiMember::Schema;
use Digest::SHA qw/ sha512_base64 /;

my $DB_NAME = "pimember.db";

my $schema = PiMember::Schema->connect("dbi:SQLite:$DB_NAME");
my $users = $schema->resultset("User");

my $error;
my $username;
my $first_name;
my $password;

do {
    $error = 0;

    print "Enter username: ";
    chomp ($username = <>);

    if ($users->find({ username => $username })) {
        print "\n! User $username already exists !\n\n";
        $error = 1;
    }
} while (!$username || $error);

do {
    print "\nEnter first name: ";
    chomp ($first_name = <>);
} while (!$first_name);

do {
    print "\nEnter password: ";
    chomp ($password = <>);
} while (!$password);


$users->create({
    username   => $username,
    first_name => $first_name,
    password   => sha512_base64($password)
});

print "\n\n*** User '$username' created! ***\n";
