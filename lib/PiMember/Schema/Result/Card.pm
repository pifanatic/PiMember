use utf8;
package PiMember::Schema::Result::Card;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PiMember::Schema::Result::Card

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

=head1 TABLE: C<Cards>

=cut

__PACKAGE__->table("Cards");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 frontside

  data_type: 'text'
  is_nullable: 0

=head2 backside

  data_type: 'text'
  is_nullable: 0

=head2 rating

  data_type: 'integer'
  is_nullable: 0

=head2 last_seen

  data_type: 'datetime'
  is_nullable: 1

=head2 due

  data_type: 'date'
  is_nullable: 1

=head2 correctly_answered

  data_type: 'integer'
  is_nullable: 1

=head2 wrongly_answered

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "frontside",
  { data_type => "text", is_nullable => 0 },
  "backside",
  { data_type => "text", is_nullable => 0 },
  "rating",
  { data_type => "integer", is_nullable => 0 },
  "last_seen",
  { data_type => "datetime", is_nullable => 1 },
  "due",
  { data_type => "date", is_nullable => 1 },
  "correctly_answered",
  { data_type => "integer", is_nullable => 1 },
  "wrongly_answered",
  { data_type => "integer", is_nullable => 1 },
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
  { "foreign.card_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-09 12:25:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9m1oDzy27nxAkqMu3GV+Ew

__PACKAGE__->many_to_many("tags", "cards_tags", "tag");

__PACKAGE__->meta->make_immutable;

1;
