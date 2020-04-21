package PiMember::Controller::Logout;
use Moose;
use namespace::autoclean;

BEGIN { extends "Catalyst::Controller"; }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    $c->logout;
    $c->response->redirect(
        $c->uri_for($c->controller("Login")->action_for("index"))
    );
}

__PACKAGE__->meta->make_immutable;

1;
