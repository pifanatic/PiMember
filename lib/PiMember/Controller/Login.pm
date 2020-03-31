package PiMember::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        my $username = $c->req->params->{"username"};
        my $password = $c->req->params->{"password"};

        if ($username && $password) {
            if ($c->authenticate({ username => $username, password => $password })) {
                $c->response->redirect($c->uri_for("/"));
            } else {
                $c->stash({ error_msg => "Incorrect username or password." });
            }
        } else {
            $c->stash({ error_msg => "Username and password required." });
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;
