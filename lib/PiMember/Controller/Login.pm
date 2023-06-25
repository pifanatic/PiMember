package PiMember::Controller::Login;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Handles the login process

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 index

The login routine

=cut

sub index : Path Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $username = $c->req->params->{username};
        my $password = $c->req->params->{password};

        if (!$username || !$password) {
            $c->res->status(400);
            return $c->stash({ error_msg => "Username and password required." });
        }

        if (!$c->authenticate({ username => $username, password => $password })) {
            return $c->stash({ error_msg => "Incorrect username or password." });
        }

        $c->forward($c->controller("Cards")->action_for("update_queue"));

        $c->response->redirect(
            $c->uri_for($c->controller("Root")->action_for("index"))
        );
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
