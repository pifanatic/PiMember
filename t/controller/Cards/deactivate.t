use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

subtest "deactivating card with no login" => sub {
    $mech->get("/cards/1/deactivate");

    $mech->header_is(
        "Status",
        302,
        "redirects when deactivating card without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when deactivating card without login"
    );
};

subtest "deactivating active card" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(1)->is_active,
        1,
        "card is currently active"
    );

    $mech->get("/cards/1/deactivate");

    $mech->header_is(
        "status",
        302,
        "redirects after deactivating card"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards/1\?mid=\d{8}$|,
        "redirects to /cards/* after deactivating a card"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card has been deactivated",
        "shows success notification after deactivating a card"
    );

    is(
        $schema->resultset("Card")->find(1)->is_active,
        0,
        "has updated is_active attribute"
    );

    reset_fixtures;
};

subtest "deactivating an inactive card" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(8)->is_active,
        0,
        "card is currently deactivated"
    );

    $mech->get("/cards/8/deactivate");

    $mech->header_is(
        "status",
        302,
        "redirects after deactivating a card"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards/8\?mid=\d{8}$|,
        "redirects to /cards/* after deactivating a card"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card has been deactivated",
        "shows success notification after deactivating a card"
    );

    is(
        $schema->resultset("Card")->find(8)->is_active,
        0,
        "card is still deactivated"
    );

    reset_fixtures;
};

subtest "try to deactivate another user's card" => sub {
    login_mech;

    $mech->get("/cards/6/deactivate");

    $mech->header_is(
        "Status",
        404,
        "has status 404 when trying to deactivate another user's card"
    );

    $mech->content_contains(
        "404 - Not Found",
        "Shows 'Not Found' message"
    );

    is(
        $schema->resultset("Card")->find(6)->is_active,
        1,
        "card is still active"
    );
}