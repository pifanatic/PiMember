package PiMember::Controller::Cards;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub add : Local Args(0) {
    
}

__PACKAGE__->meta->make_immutable;

1;
