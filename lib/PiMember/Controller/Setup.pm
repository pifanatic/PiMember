package PiMember::Controller::Setup;
use Moose;
use namespace::autoclean;
use Digest::SHA qw/ sha512_base64 /;

=head1 NAME

PiMember::Controller::Setup

=head1 DESCRIPTION

Handles the setup logic

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 index

Show a form to setup the application

=cut

sub index : Path Args(0) {
    my ($self, $c) = @_;

    if ($c->model("DB::User")->count > 0) {
        $c->response->redirect(
            $c->uri_for($c->controller("Login")->action_for("index"))
        );
        return;
    }

    if ($c->req->method eq "POST") {
        my $username     = $c->req->params->{username};
        my $password     = $c->req->params->{password};
        my $display_name = $c->req->params->{display_name};

        $c->forward($c->controller("Validator")->action_for("setup_account"));

        if (!$c->stash->{validation}) {
            $c->res->status(400);
            $c->stash({
                error_msg => "Could not create profile!"
            });
            return;
        }

        $c->model("DB::User")->create({
            username     => $username,
            display_name => $display_name,
            password     => sha512_base64($password)
        });

        $c->authenticate({
            username => $username,
            password => $password
        });

        $c->session->{queue_size} = 0;

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
