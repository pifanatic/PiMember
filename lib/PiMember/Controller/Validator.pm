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


=head1 METHODS

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
        constraint_methods => {
            username     => FV_length_between(1, 30),
            display_name => FV_length_between(1, 50)
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
            new_password        => FV_min_length(10),
            new_password_repeat => [
                FV_min_length(10),
                sub {
                    my $dfv          = shift;
                    my $data         = $dfv->get_filtered_data;
                    my $new_password = $data->{new_password} || "";

                    return $dfv->get_current_constraint_value
                           eq
                           $new_password;
                }
            ]
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
