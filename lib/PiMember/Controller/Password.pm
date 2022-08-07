package PiMember::Controller::Password;
use Moose;
use namespace::autoclean;
use Digest::SHA qw/ sha512_base64 /;

=head1 NAME

PiMember::Controller::Password - Catalyst Controller

=head1 DESCRIPTION

handles the routes for password change and password reset

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 change

Let the user change their password

=cut

sub change : Local Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $auth_params = {
            username => $c->user->username,
            password => $c->req->params->{old_password}
        };

        $c->forward($c->controller("Validator")->action_for("password_change"));

        if (!$c->stash->{validation}->success) {
            $c->res->status(400);
            $c->stash({
                error_msg => "Password change failed!"
            });
            return;
        }

        if (!$c->authenticate($auth_params)) {
            $c->res->status(401);
            $c->stash({
                error_msg => "Current password incorrect!"
            });
            return;
        }

        $c->user->update({
            password => sha512_base64($c->req->params->{new_password})
        });

        $c->res->redirect(
            $c->uri_for(
                $c->controller("Profile")->action_for("index"),
                { mid => $c->set_status_msg("Password changed successfully") }
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
