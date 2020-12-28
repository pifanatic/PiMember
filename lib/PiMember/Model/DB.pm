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
    title     => "...",
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
        title           => $args->{title},
        rating          => 0,
        created         => DateTime->today->iso8601,
        due             => DateTime->today->iso8601,
        correct_answers => 0,
        wrong_answers   => 0,
    });

    if (@tags > 0) {
        @tags = map {
            $self->resultset("Tag")->find_or_create({ name => $_ });
        } @tags;

        $new_card->set_tags(@tags);
    }

    return $new_card;
}


=head2 update_card

Update the I<title>, I<frontside>, I<backside> and I<tags> attributes of a given
card.

Returns the updated card.

=cut

sub update_card {
    my ($self, $card, $args) = @_;

    my @tags = @{ $args->{tags} };

    $card->update({
        title     => $args->{title},
        frontside => $args->{frontside},
        backside  => $args->{backside}
    });

    $card->cards_tags->delete;

    if (@tags > 0) {
        @tags = map {
            $self->resultset("Tag")->find_or_create({ name => $_ });
        } @tags;

        $card->set_tags(@tags);
    }

    return $card;
}


=head2 get_due_cards

Returns a result set that contains all cards that are due to learn ordered by
their last_seen value.

=cut

sub get_due_cards {
    my ($self) = @_;

    return $self->resultset("Card")->search(
        {
            due      => { "<=" => DateTime->now->iso8601 },
            in_trash => 0
        },
        {
            order_by => { -asc => "last_seen" }
        }
    );
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
