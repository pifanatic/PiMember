package PiMember::Controller::Cards;
use Moose;
use namespace::autoclean;

use DateTime;

BEGIN { extends 'Catalyst::Controller'; }

sub add : Local Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq "POST") {
        my $title      = $c->req->params->{title};
        my $front_text = $c->req->params->{frontText};
        my $back_text  = $c->req->params->{backText};
        my $now        = DateTime->now;

        $c->model("DB::Card")->create({
            title              => $title,
            frontside          => $front_text,
            backside           => $back_text,
            rating             => 0,
            last_seen          => $now,
            due                => $now,
            correctly_answered => 0,
            wrongly_answered   => 0,
        });

        $c->stash({
            success_msg => qq/"$title" has been created!/
        });
    }
}

__PACKAGE__->meta->make_immutable;

1;
