use utf8;
package PiMember::Schema::Result::Card;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PiMember::Schema::Result::Card

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

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

=head2 category_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 rating

  data_type: 'integer'
  is_nullable: 0

=head2 last_seen

  data_type: 'date'
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
  "category_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "rating",
  { data_type => "integer", is_nullable => 0 },
  "last_seen",
  { data_type => "date", is_nullable => 1 },
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

=head2 category

Type: belongs_to

Related object: L<PiMember::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "PiMember::Schema::Result::Category",
  { id => "category_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-03 10:27:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:waSQ5PO0+5ed82XByYZqeg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
