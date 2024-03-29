package PiMember::Controller::Profile;
use Moose;
use namespace::autoclean;

=head1 NAME

PiMember::Controller::Profile

=head1 DESCRIPTION

Handles the user's profile

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 index

Show the user's profile

=cut

sub index : Path Args(0) {}

=head2 edit

Allow user to edit their profile

=cut

sub edit: Local Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $username = $c->req->params->{username};

        $c->forward($c->controller("Validator")->action_for("profile"));

        if (!$c->stash->{validation}) {
            $c->res->status(400);
            $c->stash({
                error_msg => "Profile update failed!"
            });
            return;
        }

        if ($c->user->username ne $username &&
            $c->model("DB::User")->find({ username => $username })) {
                $c->res->status(400);
                $c->stash({
                    error_msg => 'Username "' .
                                 $c->req->params->{username} .
                                 '" is already taken!'
                });
                return;
        }

        $c->model("DB::User")->find($c->user->id)->update({
            username        => $c->req->params->{username},
            display_name    => $c->req->params->{display_name},
            mathjax_enabled => $c->req->params->{mathjax_enabled} ? 1 : 0,
            max_rating      => int(0 . $c->req->params->{max_rating})
        });

        $c->res->redirect(
            $c->uri_for($c->controller->action_for("index"),
                { mid => $c->set_status_msg("Profile updated!") }
            )
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
