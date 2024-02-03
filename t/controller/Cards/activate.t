use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

subtest "activating card with no login" => sub {
    $mech->get("/cards/8/activate");

    $mech->header_is(
        "Status",
        302,
        "redirects when activating card without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when activating card without login"
    );
};

subtest "activating inactive card" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(8)->is_active,
        0,
        "card is currently inactive"
    );

    $mech->get("/cards/8/activate");

    $mech->header_is(
        "status",
        302,
        "redirects after activating card"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards/8\?mid=\d{8}$|,
        "redirects to /cards/* after activating a card"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card has been activated",
        "shows success notification after activating a card"
    );

    is(
        $schema->resultset("Card")->find(8)->is_active,
        1,
        "has updated is_active attribute"
    );

    reset_fixtures;
};

subtest "activating an active card" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(1)->is_active,
        1,
        "card is currently active"
    );

    $mech->get("/cards/1/activate");

    $mech->header_is(
        "status",
        302,
        "redirects after activating a card"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards/1\?mid=\d{8}$|,
        "redirects to /cards/* after activating a card"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card has been activated",
        "shows success notification after activating a card"
    );

    is(
        $schema->resultset("Card")->find(1)->is_active,
        1,
        "card is still active"
    );

    reset_fixtures;
};

subtest "try to activate another user's card" => sub {
    login_mech;

    $mech->get("/cards/9/activate");

    $mech->header_is(
        "Status",
        404,
        "has status 404 when trying to activate another user's card"
    );

    $mech->content_contains(
        "404 - Not Found",
        "Shows 'Not Found' message"
    );

    is(
        $schema->resultset("Card")->find(9)->is_active,
        0,
        "card is still inactive"
    );
}