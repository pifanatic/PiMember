package PiMember::Controller::Logout;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::Controller::Logout - Catalyst Controller

=head1 DESCRIPTION

Handles the logout process

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 index

The logout routine

=cut

sub index : Path Args(0) {
    my ($self, $c) = @_;

    $c->delete_session;
    $c->logout;

    $c->response->redirect(
        $c->uri_for($c->controller("Login")->action_for("index"))
    );
}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
