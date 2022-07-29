package PiMember::Controller::Profile;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::Controller::Profile

=head1 DESCRIPTION

Handles the user's profile

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 index

Show the user's profile

=cut

sub index : Path Args(0) {}

=head2 edit

Allow user to edit their profile

=cut

sub edit: Local Args(0) {}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
