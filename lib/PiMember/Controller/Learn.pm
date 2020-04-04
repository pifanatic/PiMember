package PiMember::Controller::Learn;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    my $next_card_to_learn = $c->model("DB::Card")->search({
        due => { "<=" => DateTime->now->ymd }
    })->next;

    if ($next_card_to_learn) {
        $c->stash({
            card => $next_card_to_learn
        });
    } else {
        $c->stash({
            template => "learn/nothing_to_learn.tt"
        });
    }
}

__PACKAGE__->meta->make_immutable;

1;
