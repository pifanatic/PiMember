package PiMember::Controller::Tags;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::Controller::Tags

=head1 DESCRIPTION

Handles all actions referring to tags.

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 index

Retrieve all tags from the database and stash them in order to show a list of
all tags.

=cut

sub index : Path Args(0) {
    my ($self, $c) = @_;

    my @tags = $c->model("DB::Tag")->all;

    $c->stash({
        tags => \@tags
    });
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