package PiMember::Controller::Root;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::Controller::Root - Catalyst Controller

=head1 DESCRIPTION

Handles the app's home page and defines behaviour that is common for all
requests.

=cut

BEGIN { extends "Catalyst::Controller" }

__PACKAGE__->config(namespace => "");


=head1 METHODS

=head2 begin

Common routines that need to be done for all requests.

=cut

sub begin : Private {
    my ($self, $c) = @_;

    if ($c->user_exists && $c->req->path eq "login") {
        $c->response->redirect(
            $c->uri_for($c->controller("Root")->action_for("index"))
        );
        $c->detach;
    }

    if (!$c->user_exists && $c->req->path ne "login") {
        $c->response->redirect(
            $c->uri_for($c->controller("Login")->action_for("index"))
        );
        $c->detach;
    }

    $c->load_status_msgs;
}


=head2 index

The welcome screen of the application

=cut

sub index : Path Args(0) {}


=head2 default

Common "404 Not Found" page

=cut

sub default : Path {
    my ($self, $c) = @_;

    $c->response->status(404);
}


=head2 end

Render view that corresponds to the controller and show a custom error screen
if there are any errors

=cut

sub end : ActionClass("RenderView") {
    my ($self, $c) = @_;

    if ($c->has_errors) {
        $c->log->fatal($_) for @{$c->error};
        $c->clear_errors;

        $c->stash({
            template => "error.tt"
        });
    }
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
