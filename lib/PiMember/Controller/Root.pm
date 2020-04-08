package PiMember::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub begin : Private {
    my ($self, $c) = @_;

    if (!$c->user_exists() && $c->req->path ne "login") {
        $c->response->redirect(
            $c->uri_for($c->controller("Login")->action_for("index"))
        );
    }

    my $number_of_due_cards = $c->model("DB::Card")->count({
        due => { "<=" => DateTime->now }
    });

    $c->stash({
        number_of_due_cards => $number_of_due_cards
    });
}

sub index : Path Args(0) {}

sub default : Path {
    my ($self, $c) = @_;

    $c->response->status(404);
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;
