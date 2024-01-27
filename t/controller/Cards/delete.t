use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "deleting a card with no login" => sub {
    $mech->get("/cards/1/delete");

    $mech->header_is(
        "Status",
        302,
        "redirects when deleting a card without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when deleting a card"
    );
};

subtest "deleting a card" => sub {
    login_mech;

    ok(
        $schema->resultset("Card")->find(1),
        "card exists"
    );

    $mech->get("/cards/1/delete");

    $mech->header_is(
        "status",
        302,
        "redirects after deleting"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/trash\?mid=\d{8}$|,
        "redirects to /trash after deleting a card"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card has been deleted",
        "shows success notification after deleting a card"
    );

    ok(
        !$schema->resultset("Card")->find(1),
        "has deleted the card"
    );

    is(
        $schema->resultset("CardsTag")->search({ card_id => 1 })->count,
        0,
        "has deleted all cards tags"
    );

    ok(
        $schema->resultset("Tag")->find(1),
        "tag that is still used exists"
    );

    ok(
        !$schema->resultset("Tag")->find(2),
        "unused tag was deleted"
    );

    reset_fixtures;
};

subtest "try to delete another user's card" => sub {
    login_mech;

    $mech->get("/cards/6/delete");

    $mech->header_is(
        "Status",
        404,
        "has status 404 when trying to delete another user's card"
    );

    $mech->content_contains(
        "404 - Not Found",
        "Shows 'Not Found' message"
    );

    ok(
        $schema->resultset("Card")->find(6),
        "card is still there"
    );
};

subtest "try to delete non-existing card" => sub {
    login_mech;

    $mech->get("/cards/66/delete");

    $mech->header_is(
        "Status",
        404,
        "has status 404 when trying to delete non-existing card"
    );

    $mech->content_contains(
        "404 - Not Found",
        "Shows 'Not Found' message"
    );
};