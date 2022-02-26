package PiMember::Controller::Cards;
use Moose;
use namespace::autoclean;

use DateTime;

=head1 NAME

PiMember::Controller::Cards

=head1 DESCRIPTION

Handles all actions referring to cards.

=cut

BEGIN { extends "Catalyst::Controller"; }

=head1 METHODS

=head2 index

Retrieve all cards from the database and stash them in order to show a list of
all cards.

Show only cards with a specific tag if the I<tag> URL parameter is given.

=cut

sub index : Path Args(0) {
    my ($self, $c) = @_;

    my $tag = $c->req->params->{tag};
    my $cards = $c->model("DB::Card")->search({ in_trash => 0 });

    if ($tag) {
        $cards = $cards->search(
            {
                "tag.name" => lc $tag
            },
            {
                join     => { cards_tags => { tag => "cards_tags" } },
                collapse => 1
            }
        );

        $c->stash({ tag => lc $tag });
    }

    $c->stash({ cards => [$cards->all] });
}


=head2 add

GET shows a form to enter all values for a new card.

POST creates a new card in the database with the given form-data.

=cut

sub add : Local Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $new_card = $c->model("DB")->create_card({
            frontside => $c->req->params->{frontside},
            backside  => $c->req->params->{backside},
            title     => $c->req->params->{title},
            tags      => [split " ", $c->req->params->{tags} ],
            user_id   => $c->user->id
        });

        $c->forward($self->action_for("update_queue"));

        $c->response->redirect($c->uri_for(
            $c->controller->action_for("add"),
            { mid => $c->set_status_msg('"' . $new_card->title . '" has been created!') }
        ));
    }
}


=head2 get_card_by_id

The base action for all actions that manipulate one single existing card.

This action searches for a specific card by its id and stashes it if it could
be found, and goes to the default 404 page if it could not be found.

=cut

sub get_card_by_id : Chained("/") PathPart("cards") CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    my $card = $c->model("DB::Card")->find($id);

    if (!$card) {
        $c->go($c->controller("Root")->action_for("default"));
    }

    $c->stash({ card => $card });
}

=head2 view

Show all information about a card.

=cut

sub view : Chained("get_card_by_id") PathPart("") { }


=head2 edit

Changes the I<title>, I<frontside>, I<backside> or I<tags> of a card. Note that
all other attributes (like I<rating> or I<due>) will not be affected by this.

GET shows a form filled with the current values of this card in order to change
them.

POST will update the values of the card with the given form-data and redirect
to the 'edit' page with the updated value afterwards.

=cut

sub edit : Chained("get_card_by_id") Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        $c->stash->{card} = $c->model("DB")->update_card(
            $c->stash->{card},
            {
                title     => $c->req->params->{title},
                frontside => $c->req->params->{frontside},
                backside  => $c->req->params->{backside},
                tags      => [ split " ", $c->req->params->{tags} ]
            }
        );

        my $status_msg = '"' . $c->stash->{card}->title . '" edited successfully!';

        $c->forward($c->controller("Tags")->action_for("remove_unused_tags"));

        $c->response->redirect(
            $c->uri_for(
                $c->controller->action_for("view"),
                [ $c->stash->{card}->id ],
                { mid => $c->set_status_msg($status_msg) }
            )
        );
    }

    $c->stash({
        tags => join(" ", map { $_->name } $c->stash->{card}->tags)
    });
}


=head2 learn

Learn a card.

GET will show the learn form for the next card in queue or a hint that all cards
have been learned already

POST will update the card according to the value of the given B<correct>
form-data value. Redirect to the next due card afterwards.

=cut

sub learn : Local Args(0) {
    my ($self, $c) = @_;

    my $tag = $c->req->query_parameters->{tag};

    if ($c->req->method eq "GET") {
        my $card;

        if ($tag) {
            $card = $c->model("DB")->get_due_cards_by_tag($tag)->first;

            $c->stash({ tag => $tag });
        } else {
            $card = $c->model("DB")->get_due_cards->first;
        }

        $c->stash({ card => $card });
        $c->detach;
    }

    if ($c->req->method eq "POST") {
        my $correct = $c->req->params->{correct};
        my $card_id = $c->req->params->{id};

        my $card = $c->model("DB::Card")->find($card_id);

        $card->give_answer($correct);

        $c->forward($self->action_for("update_queue"));

        $c->response->redirect(
            $c->uri_for($self->action_for("learn"), $c->req->query_parameters)
        );
    }
}

=head2 search

Search for cards whose title/frontside/backside matches a given query string

=cut

sub search : Local Args(0) {
    my ($self, $c) = @_;

    my @cards;
    my $query = $c->req->query_parameters->{q};

    if ($query) {
        @cards = $c->model("DB::Card")->search({
            -or => {
                title     => { "like" => "%$query%" },
                frontside => { "like" => "%$query%" },
                backside  => { "like" => "%$query%" },
            },
            in_trash => 0
        });
    }

    $c->stash({
        query => $query,
        cards => \@cards
    });
}

=head2 movetotrash

Move a card to trash and return to the card list

=cut

sub movetotrash : Chained("get_card_by_id") Args(0) {
    my ($self, $c) = @_;

    $c->stash->{card}->update({
        in_trash => 1
    });

    $c->forward($self->action_for("update_queue"));

    my $status_msg = '"' . $c->stash->{card}->title . '" has been moved to trash';

    $c->response->redirect(
        $c->uri_for(
            $self->action_for("index"),
            { mid => $c->set_status_msg($status_msg) }
        )
    );
}

=head2 restore

Restores a card that had been moved to trash

=cut

sub restore : Chained("get_card_by_id") Args(0) {
    my ($self, $c) = @_;

    if ($c->stash->{card}->in_trash ne 1) {
        my $error_msg = "Could not restore card!";

        $c->response->redirect(
            $c->uri_for(
                $self->action_for("index"),
                { mid => $c->set_error_msg($error_msg) }
            )
        );

        $c->detach;
    } else {
        $c->stash->{card}->update({ in_trash => 0 });

        $c->forward($self->action_for("update_queue"));

        my $status_msg = "'" . $c->stash->{card}->title . "' has been restored";

        $c->response->redirect(
            $c->uri_for(
                $c->controller("Trash")->action_for("index"),
                { mid => $c->set_status_msg($status_msg) }
            )
        );
    }
}

=head2 delete

Delete a card permanently

=cut

sub delete : Chained("get_card_by_id") Args(0) {
    my ($self, $c) = @_;

    $c->stash->{card}->delete;

    $c->forward($c->controller("Tags")->action_for("remove_unused_tags"));

    my $status_msg = "'" . $c->stash->{card}->title . "' has been deleted";

    $c->response->redirect(
        $c->uri_for(
            $c->controller("Trash")->action_for("index"),
            { mid => $c->set_status_msg($status_msg) }
        )
    );
}

=head2 update_queue

Update the queue of cards that are due

=cut

sub update_queue : Private {
    my ($self, $c) = @_;

    $c->session->{queue_size} = $c->model("DB")->get_due_cards->count;
}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
