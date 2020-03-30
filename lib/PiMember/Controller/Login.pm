package PiMember::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Path Args(0) { }

__PACKAGE__->meta->make_immutable;

1;
