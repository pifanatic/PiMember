package PiMember::Controller::Validator;
use Moose;
use Data::FormValidator;
use Data::FormValidator::Constraints qw/
    FV_length_between
    FV_min_length
/;

=head1 NAME

PiMember::Controller::Validator

=head1 DESCRIPTION

Validates form-data

=cut

BEGIN { extends "Catalyst::Controller"; }

my $username_constraint     = FV_length_between(1, 30);
my $display_name_constraint = FV_length_between(1, 50);
my $password_constraint     = FV_min_length(10);

=head1 METHODS

=head2 must_match

Check if a given value matches the current constraint value

=cut

sub must_match {
    my $value = shift;

    return sub {
        my $dfv       = shift;
        my $data      = $dfv->get_filtered_data;
        my $new_value = $data->{$value} || "";

        return $dfv->get_current_constraint_value
                eq
                $new_value;
    }
};

=head2 is_integer

Check if a given value is a integer

=cut

sub is_integer {
    return sub {
        my $dfv = shift;

        $dfv->get_current_constraint_value =~ /^\d*$/
    }
}

=head2 profile

Check if the given form-data is a valid profile

=cut

sub profile : Private {
    my ($self, $c) = @_;

    my $profile = {
        required => [
            "username",
            "display_name"
        ],
        optional => [
            "max_rating"
        ],
        constraint_methods => {
            username     => $username_constraint,
            display_name => $display_name_constraint,
            max_rating   => is_integer
        }
    };

    my $validation = Data::FormValidator->check($c->req->params, $profile);

    $c->stash({
        validation => $validation
    });
}

=head2 password_change

Check if the given form-data is a valid for a password change

=cut

sub password_change : Private {
    my ($self, $c) = @_;

    my $profile = {
        required => [
            "old_password",
            "new_password",
            "new_password_repeat"
        ],
        constraint_methods => {
            new_password        => $password_constraint,
            new_password_repeat => must_match("new_password")
        }
    };

    my $validation = Data::FormValidator->check($c->req->params, $profile);

    $c->stash({
        validation => $validation
    });
}

=head2 setup_account

Check if the given form-data is a valid to set up an account

=cut

sub setup_account : Private {
    my ($self, $c) = @_;

    my $profile = {
        required => [
            "username",
            "display_name",
            "password",
            "confirm_password"
        ],
        constraint_methods => {
            username         => $username_constraint,
            display_name     => $display_name_constraint,
            password         => $password_constraint,
            confirm_password => must_match("password")
        }
    };

    my $validation = Data::FormValidator->check($c->req->params, $profile);

    $c->stash({
        validation => $validation
    });
}

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
