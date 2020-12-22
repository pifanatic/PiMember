package PiMember::Controller::Trash;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::Controller::Trash

=head1 DESCRIPTION

Handles the trash

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 auto

Get all cards that are in trash

This is an operation that is needed for all actions in this controller

=cut

sub auto : Private {
    my ($self, $c) = @_;

    my @cards_in_trash = $c->model("DB::Card")->search({ in_trash => 1 });

    $c->stash({ cards => \@cards_in_trash });
}

=head2 index

Show all cards that are in trash as of now.

=cut

sub index : Path Args(0) {}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
