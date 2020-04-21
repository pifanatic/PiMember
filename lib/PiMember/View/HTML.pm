package PiMember::View::HTML;
use Moose;
use namespace::autoclean;

extends "Catalyst::View::TT";

__PACKAGE__->config(
    TEMPLATE_EXTENSION => ".tt",
    render_die         => 1,
    WRAPPER            => "wrapper.tt"
);

1;
