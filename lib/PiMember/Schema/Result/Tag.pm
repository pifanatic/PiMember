use utf8;
package PiMember::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PiMember::Schema::Result::Tag

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<Tags>

=cut

__PACKAGE__->table("Tags");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 cards_tags

Type: has_many

Related object: L<PiMember::Schema::Result::CardsTag>

=cut

__PACKAGE__->has_many(
  "cards_tags",
  "PiMember::Schema::Result::CardsTag",
  { "foreign.tag_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<PiMember::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "PiMember::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-02-27 20:59:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IZAdvhIqPBRcjFcJr6NJOw

=head1 ADDITIONAL ACCESSORS

=head2 card_count

Number of cards that have this tag

=cut

has card_count => (
    is      => "ro",
    isa     => "Int",
    lazy    => 1,
    builder => "_build_card_count"
);

sub _build_card_count {
    my ($self) = @_;

    return $self->cards->count;
}

=head2 due_cards

Cards with this tag that are due

=cut

has due_cards => (
    is      => "ro",
    isa     => "ArrayRef[PiMember::Schema::Result::Card]",
    lazy    => 1,
    builder => "_build_due_cards"
);

sub _build_due_cards {
    my ($self) = @_;

    my @due_cards = grep { $_->is_due } $self->cards;

    return \@due_cards;
}


__PACKAGE__->many_to_many("cards", "cards_tags", "card");

__PACKAGE__->meta->make_immutable;

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
