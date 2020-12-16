package PiMember::ActionRole::UpdateQueue;

use Moose::Role;

=head1 NAME

PiMember::ActionRole::UpdateQueue;

=head1 DESCRIPTION

ActionRole that updates the queue of all cards that need to be learned by
querying the database.

Update will only be made after a POST request since this is the only request
type that can actually have an impact on the cards that are due.

=cut

after "execute" => sub {
    my ($self, $controller, $c) = @_;

    if ($c->req->method eq "POST") {
        my @cards_to_learn = $c->model("DB::Card")->search({
                due      => { "<=" => DateTime->now->iso8601 },
                in_trash => 0
            },
            { order_by => { -asc => "last_seen" } }
        );

        $c->session->{queue} = \@cards_to_learn;
    }
};

1;

=encoding utf8

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
