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

=head2 correct_answers

  data_type: 'integer'
  is_nullable: 1

=head2 wrong_answers

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
  "correct_answers",
  { data_type => "integer", is_nullable => 1 },
  "wrong_answers",
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


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-09 13:20:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VT2hriUXZV9+XEpnKTLiXg

has success_rate => (
    is      => "ro",
    isa     => "Int",
    lazy    => 1,
    builder => "_build_success_rate"
);

sub _build_success_rate {
    my ($self) = @_;

    return 0 if $self->total_answers == 0;

    return int(100 * $self->correct_answers / $self->total_answers);
}

has total_answers => (
    is      => "ro",
    isa     => "Int",
    lazy    => 1,
    builder => "_build_total_answers"
);

sub _build_total_answers {
    my ($self) = @_;

    return $self->correct_answers + $self->wrong_answers;
}

sub give_answer {
    my ($self, $answered_correctly) = @_;

    $answered_correctly
        ? $self->update_for_correct_answer
        : $self->update_for_wrong_answer;
}

sub update_for_correct_answer {
    my ($self) = @_;

    my $new_rating = $self->rating + 1;

    $self->update({
        rating          => $new_rating,
        last_seen       => DateTime->now->iso8601,
        due             => DateTime->today->add({ days => $new_rating })->iso8601,
        correct_answers => $self->correct_answers + 1
    });
}

sub update_for_wrong_answer {
    my ($self) = @_;

    $self->update({
        rating        => 0,
        last_seen     => DateTime->now->iso8601,
        due           => DateTime->today->iso8601,
        wrong_answers => $self->wrong_answers + 1
    });
}

__PACKAGE__->many_to_many("tags", "cards_tags", "tag");

__PACKAGE__->meta->make_immutable;

1;
