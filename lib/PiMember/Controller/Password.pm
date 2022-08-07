package PiMember::Controller::Password;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::Controller::Password - Catalyst Controller

=head1 DESCRIPTION

handles the routes for password change and password reset

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 change

Let the user change their password

=cut

sub change : Local Args(0) {}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
