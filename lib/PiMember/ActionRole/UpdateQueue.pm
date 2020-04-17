package PiMember::ActionRole::UpdateQueue;

use Moose::Role;

after "execute" => sub {
    my ($self, $controller, $c) = @_;

    # Only retrieve list of due cards from database after a change has been made
    # Such a change can only occur after a POST request
    if ($c->req->method eq "POST") {
        my @cards_to_learn = $c->model("DB::Card")->search(
            { due      => { "<=" => DateTime->now->iso8601 } },
            { order_by => { -asc => "last_seen" } }
        );

        $c->session->{queue} = \@cards_to_learn;
    }
};

1;
