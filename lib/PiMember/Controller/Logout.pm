package PiMember::Controller::Logout;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    $c->logout;
    $c->response->redirect($c->uri_for("/login"));
}

__PACKAGE__->meta->make_immutable;

1;
