package PiMember::Controller::List;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub index : Path Args(0) {
    my ($self, $c) = @_;

    my @cards = $c->model('DB')->resultset('Card')->all;

    $c->stash({
        cards => \@cards,
        count => scalar @cards
    });
}

__PACKAGE__->meta->make_immutable;

1;
