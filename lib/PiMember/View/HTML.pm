package PiMember::View::HTML;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::View::HTML

=head1 DESCRIPTION

Define and configure Template::Toolkit for this application

=cut

extends "Catalyst::View::TT";

__PACKAGE__->config(
    TEMPLATE_EXTENSION => ".tt",
    render_die         => 1,
    WRAPPER            => "wrapper.tt"
);

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
