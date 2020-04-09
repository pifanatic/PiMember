use utf8;
package PiMember::Schema::Result::CardsTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PiMember::Schema::Result::CardsTag

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

=head1 TABLE: C<CardsTags>

=cut

__PACKAGE__->table("CardsTags");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 card_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "card_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "tag_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 card

Type: belongs_to

Related object: L<PiMember::Schema::Result::Card>

=cut

__PACKAGE__->belongs_to(
  "card",
  "PiMember::Schema::Result::Card",
  { id => "card_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 tag

Type: belongs_to

Related object: L<PiMember::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "PiMember::Schema::Result::Tag",
  { id => "tag_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-09 12:25:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0e3NcTZkd1kk62+IYrSSFA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
