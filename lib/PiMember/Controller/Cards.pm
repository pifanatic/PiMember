package PiMember::Controller::Cards;
use Moose;
use namespace::autoclean;

use DateTime;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    my @cards = $c->model("DB::Card")->all;

    $c->stash({
        cards => \@cards,
        count => scalar @cards
    });
}

sub add : Local Args(0) {
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

sub edit : Local Args(1) {
    my ($self, $c, $id) = @_;

    my $card = $c->model("DB::Card")->search({
        id => $id
    })->next;

    if (!$card) {
        $c->go($c->controller("Root")->action_for("default"));
    }

    if ($c->req->method eq "POST") {
        my $title     = $c->req->params->{"title"};
        my $frontside = $c->req->params->{"frontside"};
        my $backside  = $c->req->params->{"backside"};
        my @tags      = split " ", $c->req->params->{tags};

        $card->update({
            title     => $title,
            frontside => $frontside,
            backside  => $backside
        });

        $card->cards_tags->delete;

        if (@tags) {
            @tags = map {
                $c->model("DB::Tag")->find_or_create({ name => $_ });
            } @tags;

            $card->set_tags(@tags);
        }

        $c->stash({
            success_msg => '"' . $card->title . '" edited successfully!'
        });
    }

    $c->stash({
        title              => 'Edit "' . $card->title . '"',
        card               => $card,
        tags               => join(" ", map { $_->name } $card->tags),
        submit_button_text => "Save",
        template           => "cards/add_edit.tt"
    });
}

sub learn : Local Args(0) {
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
        my $id = $c->req->params->{"id"};
        my $correct = $c->req->params->{"correct"};

        my $card = $c->model("DB::Card")->search({
            id => $id
        })->next;

        if ($correct) {
            $card->update({
                rating          => $card->rating + 1,
                last_seen       => DateTime->now->iso8601,
                due             => DateTime->today->add({ days => $card->rating + 1 })->iso8601,
                correct_answers => $card->correct_answers + 1
            });
        } else {
            $card->update({
                rating        => 0,
                last_seen     => DateTime->now->iso8601,
                due           => DateTime->today->iso8601,
                wrong_answers => $card->wrong_answers + 1
            });
        }

        $c->response->redirect($c->uri_for($self->action_for('learn')));
    }
}

__PACKAGE__->meta->make_immutable;

1;
