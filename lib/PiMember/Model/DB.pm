package PiMember::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'PiMember::Schema',

    connect_info => {
        dsn => 'dbi:SQLite:pimember.db',
        user => '',
        password => '',
        on_connect_do => q{PRAGMA foreign_keys = ON},
        sqlite_unicode => 1
    }
);

=head1 NAME

PiMember::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<PiMember>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<PiMember::Schema>


=head1 METHODS

=head2 create_card

Creates a new card in the database.

Parameters must be given as a hashref like this:

{
    frontside => "...",
    backside  => "...",
    tags      => [...]
}

Returns the newly created card

=cut

sub create_card {
    my ($self, $args) = @_;

    my @tags = @{ $args->{tags} };

    my $new_card = $self->resultset("Card")->create({
        frontside       => $args->{frontside},
        backside        => $args->{backside},
        rating          => 0,
        created         => DateTime->today->iso8601,
        due             => DateTime->today->iso8601,
        correct_answers => 0,
        wrong_answers   => 0,
        user_id         => $args->{user_id}
    });

    if (@tags > 0) {
        @tags = map { lc } @tags;

        @tags = map {
            $self->resultset("Tag")->find_or_create({
                name    => $_,
                user_id => $args->{user_id}
            });
        } @tags;

        $new_card->set_tags(@tags);
    }

    return $new_card;
}


=head2 update_card

Update the I<frontside>, I<backside> and I<tags> attributes of a given
card.

Returns the updated card.

=cut

sub update_card {
    my ($self, $card, $args) = @_;

    my @tags = @{ $args->{tags} };

    $card->update({
        frontside => $args->{frontside},
        backside  => $args->{backside}
    });

    $card->cards_tags->delete;

    if (@tags > 0) {
        @tags = map {
            $self->resultset("Tag")->find_or_create({
                name    => $_,
                user_id => $args->{user_id}
            });
        } @tags;

        $card->set_tags(@tags);
    }

    return $card;
}

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.65

=head1 AUTHOR

Kai

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
