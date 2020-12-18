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

=cut

sub index : Path Args(0) {
    my ($self, $c) = @_;

    my @cards = $c->model("DB::Card")->search({ in_trash => 0 });

    $c->stash({ cards => \@cards });
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
            tags      => [split " ", $c->req->params->{tags} ]
        });

        $c->forward($self->action_for("update_queue"));

        $c->response->redirect($c->uri_for(
            $c->controller->action_for("add"),
            { mid => $c->set_status_msg('"' . $new_card->title . '" has been created!') }
        ));
    }

    $c->stash({
        title              => "Add a new card",
        submit_button_text => "Create",
        template           => "cards/add_edit.tt"
    });
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

        $c->response->redirect(
            $c->uri_for(
                $c->controller->action_for("edit"),
                [ $c->stash->{card}->id ],
                { mid => $c->set_status_msg($status_msg) }
            )
        );
    }

    $c->stash({
        title              => 'Edit "' . $c->stash->{card}->title . '"',
        tags               => join(" ", map { $_->name } $c->stash->{card}->tags),
        submit_button_text => "Save",
        template           => "cards/add_edit.tt"
    });
}


=head2 go_to_next_card

Finds the next card to learn from the session and goes to the 'learn' action for
that card.

The 'Nothing to learn' page will be displayed if there is no card to learn.

=cut

sub go_to_next_card : Path("learn") Args(0) {
    my ($self, $c) = @_;

    my $next_card_to_learn = $c->session->{queue}->[0];

    if ($next_card_to_learn) {
        $c->go(
            $self->action_for("learn"),
            [ $next_card_to_learn->id ],
            [ $c ]
        );
    } else {
        $c->stash({ template => "cards/nothing_to_learn.tt" });
    }
}


=head2 learn

Learn a card.

GET will show the learn form.

POST will update the card according to the value of the given B<correct>
form-data value. Redirect to the next due card afterwards.

=cut

sub learn : Chained("get_card_by_id") Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $correct = $c->req->params->{correct};

        $c->stash->{card}->give_answer($correct);

        $c->forward($self->action_for("update_queue"));

        $c->response->redirect(
            $c->uri_for($self->action_for("go_to_next_card"))
        );
    }
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

    $c->forward($self->action_for("update_queue"));

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

    my @cards_to_learn = $c->model("DB::Card")->search({
            due      => { "<=" => DateTime->now->iso8601 },
            in_trash => 0
        },
        { order_by => { -asc => "last_seen" } }
    );

    $c->session->{queue} = \@cards_to_learn;
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
