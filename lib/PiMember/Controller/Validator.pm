package PiMember::Controller::Validator;
use Moose;
use Data::FormValidator;
use Data::FormValidator::Constraints qw/ FV_length_between /;

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

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
