package PiMember::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends "Catalyst::Controller"; }

sub begin : Private {
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->response->redirect(
            $c->uri_for($c->controller("Root")->action_for("index"))
        );
    }
}

sub index : Path Args(0) Does("UpdateQueue") {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $username = $c->req->params->{username};
        my $password = $c->req->params->{password};

        if (!$username || !$password) {
            return $c->stash({ error_msg => "Username and password required." });
        }

        if (!$c->authenticate({ username => $username, password => $password })) {
            return $c->stash({ error_msg => "Incorrect username or password." });
        }

        $c->response->redirect(
            $c->uri_for($c->controller("Root")->action_for("index"))
        );
    }
}

__PACKAGE__->meta->make_immutable;

1;
