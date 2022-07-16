#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use lib '.';
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'PiMember';
all_from 'lib/PiMember.pm';

requires 'Catalyst::Runtime' => '5.90117';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::StatusMessage';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::View::TT';
requires 'CSS::Sass';
requires 'Data::FormValidator';
requires 'DateTime';
requires 'DateTime::Format::SQLite';
requires 'Moose';
requires 'MooseX::NonMoose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
test_requires 'Test::WWW::Mechanize::Catalyst';
test_requires 'Test::XPath';
test_requires 'DBIx::Class::Fixtures';
test_requires 'Devel::Cover';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
