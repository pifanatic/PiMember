package PiMember::Controller::Learn;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "GET") {
        my $next_card_to_learn = $c->model("DB::Card")->search(
            { due      => { "<=" => DateTime->now->ymd } },
            { order_by => { -asc => "last_seen" } }
        )->next;

        if ($next_card_to_learn) {
            $c->stash({
                card => $next_card_to_learn
            });
        } else {
            $c->stash({
                template => "learn/nothing_to_learn.tt"
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

        $c->response->redirect("/learn");
    }
}

__PACKAGE__->meta->make_immutable;

1;
