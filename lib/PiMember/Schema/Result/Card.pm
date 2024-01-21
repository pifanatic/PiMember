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
use List::Util qw/ min /;

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

=head2 frontside

  data_type: 'text'
  is_nullable: 0

=head2 backside

  data_type: 'text'
  is_nullable: 0

=head2 rating

  data_type: 'integer'
  is_nullable: 0

=head2 created

  data_type: 'datetime'
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

=head2 in_trash

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "frontside",
  { data_type => "text", is_nullable => 0 },
  "backside",
  { data_type => "text", is_nullable => 0 },
  "rating",
  { data_type => "integer", is_nullable => 0 },
  "created",
  { data_type => "datetime", is_nullable => 0 },
  "last_seen",
  { data_type => "datetime", is_nullable => 1 },
  "due",
  { data_type => "date", is_nullable => 1 },
  "correct_answers",
  { data_type => "integer", is_nullable => 1 },
  "wrong_answers",
  { data_type => "integer", is_nullable => 1 },
  "in_trash",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
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
  { "foreign.card_id" => "self.id" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-03-30 16:52:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N6b+mhIrVeIOYvvyhWCeDw

=head1 ADDITIONAL ACCESSORS

=head2 success_rate

Ratio of correct answers to this card.
Rounded to an integer between 0 and 100.

=cut

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

=head2 total_answers

The sum of wrong and correct answers to this card.

=cut

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

=head2 is_due

Is this card due?

=cut

has is_due => (
    is      => "ro",
    isa     => "Bool",
    lazy    => 1,
    builder => "_build_is_due"
);

sub _build_is_due {
    my ($self) = @_;

    return !$self->in_trash &&
           DateTime->compare(
               $self->due,
               DateTime->now(time_zone => "local")
           ) eq -1;
}


=head1 METHODS

=head2 give_answer

Decides which of the two B<update_for_{correct|wrong}_answer> methods to apply
to this card.

Any true argument will update for a correct answer.

=cut

sub give_answer {
    my ($self, $answered_correctly) = @_;

    $answered_correctly
        ? $self->update_for_correct_answer
        : $self->update_for_wrong_answer;
}

=head2 update_for_correct_answer

Update the attributes of this card after a correct answer has been given.

=cut

sub update_for_correct_answer {
    my ($self) = @_;

    my $new_rating = $self->rating + 1;

    if ($self->user->max_rating > 0) {
        $new_rating = min $new_rating, $self->user->max_rating;
    }

    $self->update({
        rating          => $new_rating,
        last_seen       => DateTime->now(time_zone => "local")->iso8601,
        due             => DateTime->today(time_zone => "local")
                                   ->add({ days => $new_rating })
                                   ->iso8601,
        correct_answers => $self->correct_answers + 1
    });
}


=head2 update_for_wrong_answer

Update the attributes of this card after a wrong answer has been given.

=cut

sub update_for_wrong_answer {
    my ($self) = @_;

    $self->update({
        rating        => 0,
        last_seen     => DateTime->now(time_zone => "local")->iso8601,
        due           => DateTime->today(time_zone => "local")->iso8601,
        wrong_answers => $self->wrong_answers + 1
    });
}

__PACKAGE__->many_to_many("tags", "cards_tags", "tag");

__PACKAGE__->meta->make_immutable;

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
