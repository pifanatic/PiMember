package PiMember::Controller::Cards;
use Moose;
use namespace::autoclean;

use DateTime;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    my @cards = $c->model("DB::Card")->all;

    $c->stash({ cards => \@cards });
}

sub add : Local Args(0) Does("UpdateQueue") {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $title     = $c->req->params->{title};
        my $frontside = $c->req->params->{frontside};
        my $backside  = $c->req->params->{backside};
        my @tags      = split " ", $c->req->params->{tags};

        my $new_card = $c->model("DB::Card")->create({
            title           => $title,
            frontside       => $frontside,
            backside        => $backside,
            rating          => 0,
            due             => DateTime->today->iso8601,
            correct_answers => 0,
            wrong_answers   => 0,
        });

        if (@tags) {
            @tags = map {
                $c->model("DB::Tag")->find_or_create({ name => $_ });
            } @tags;

            $new_card->set_tags(@tags);
        }

        $c->stash({
            success_msg => qq/"$title" has been created!/
        });
    }

    $c->stash({
        title              => "Add a new card",
        submit_button_text => "Create",
        template           => "cards/add_edit.tt"
    });
}

sub find_card : Chained("/") PathPart("cards") CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    my $card = $c->model("DB::Card")->search({
        id => $id
    })->next;

    if (!$card) {
        $c->go($c->controller("Root")->action_for("default"));
    }

    $c->stash({ card => $card });
}

sub edit : Chained("find_card") Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $title     = $c->req->params->{title};
        my $frontside = $c->req->params->{frontside};
        my $backside  = $c->req->params->{backside};
        my @tags      = split " ", $c->req->params->{tags};

        $c->stash->{card}->update({
            title     => $title,
            frontside => $frontside,
            backside  => $backside
        });

        $c->stash->{card}->cards_tags->delete;

        if (@tags) {
            @tags = map {
                $c->model("DB::Tag")->find_or_create({ name => $_ });
            } @tags;

            $c->stash->{card}->set_tags(@tags);
        }

        $c->stash({
            success_msg => '"' . $c->stash->{card}->title . '" edited successfully!'
        });
    }

    $c->stash({
        title              => 'Edit "' . $c->stash->{card}->title . '"',
        tags               => join(" ", map { $_->name } $c->stash->{card}->tags),
        submit_button_text => "Save",
        template           => "cards/add_edit.tt"
    });
}

sub learn : Local Args(0) Does("UpdateQueue") {
    my ($self, $c) = @_;

    if ($c->req->method eq "GET") {
        my $next_card_to_learn = $c->model("DB::Card")->search(
            { due      => { "<=" => DateTime->now->iso8601 } },
            { order_by => { -asc => "last_seen" } }
        )->next;

        if ($next_card_to_learn) {
            $c->stash({
                card => $next_card_to_learn
            });
        } else {
            $c->stash({
                template => "cards/nothing_to_learn.tt"
            });
        }
    } elsif ($c->req->method eq "POST") {
        my $id = $c->req->params->{id};
        my $correct = $c->req->params->{correct};

        my $card = $c->model("DB::Card")->search({
            id => $id
        })->next;

        $card->give_answer($correct);

        $c->response->redirect($c->uri_for($self->action_for('learn')));
    }
}

__PACKAGE__->meta->make_immutable;

1;
