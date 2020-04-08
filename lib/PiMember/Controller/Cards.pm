package PiMember::Controller::Cards;
use Moose;
use namespace::autoclean;

use DateTime;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    my @cards = $c->model('DB')->resultset('Card')->all;

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
        my $now       = DateTime->now;

        my $new_card = $c->model("DB::Card")->create({
            title              => $title,
            frontside          => $frontside,
            backside           => $backside,
            rating             => 0,
            last_seen          => $now,
            due                => $now,
            correctly_answered => 0,
            wrongly_answered   => 0,
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
}

sub learn : Local Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "GET") {
        my $next_card_to_learn = $c->model("DB::Card")->search(
            { due      => { "<=" => DateTime->now } },
            { order_by => { -asc => "last_seen" } }
        )->next;

        if ($next_card_to_learn) {
            $c->stash({
                card => $next_card_to_learn
            });
        } else {
            $c->stash({
                template => "nothing_to_learn.tt"
            });
        }
    } elsif ($c->req->method eq "POST") {
        my $id = $c->req->param("id");
        my $correct = $c->req->param("correct");

        my $card = $c->model("DB::Card")->search({
            id => $id
        })->next;

        if ($correct) {
            $card->update({
                rating             => $card->rating + 1,
                last_seen          => DateTime->now,
                due                => DateTime->now->add({ days => $card->rating + 1 }),
                correctly_answered => $card->correctly_answered + 1
            });
        } else {
            $card->update({
                rating           => 0,
                last_seen        => DateTime->now,
                due              => DateTime->now,
                wrongly_answered => $card->wrongly_answered + 1
            });
        }

        $c->response->redirect($c->uri_for($self->action_for('learn')));
    }
}

__PACKAGE__->meta->make_immutable;

1;
