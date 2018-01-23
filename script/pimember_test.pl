#!/usr/bin/env perl

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('PiMember', 'Test');

1;

=head1 NAME

pimember_test.pl - Catalyst Test

=head1 SYNOPSIS

pimember_test.pl [options] uri

 Options:
   --help    display this help and exits

 Examples:
   pimember_test.pl http://localhost/some_action
   pimember_test.pl /some_action

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst action from the command line.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=cut
