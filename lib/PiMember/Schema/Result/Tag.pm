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

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-09 12:25:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tYfddQNQGdjC38CQY71PNQ

__PACKAGE__->many_to_many("cards", "cards_tags", "card");

__PACKAGE__->meta->make_immutable;

1;
