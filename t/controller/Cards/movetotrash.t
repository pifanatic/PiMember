use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "moving card to trash with no login" => sub {
    $mech->get("/cards/1/movetotrash");

    $mech->header_is(
        "Status",
        302,
        "redirects when moving card to trash without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when moving card to trash without login"
    );
};

subtest "moving card to trash" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(1)->in_trash,
        0,
        "card is currently not in trash"
    );

    $mech->get("/cards/1/movetotrash");

    $mech->header_is(
        "status",
        302,
        "redirects after moving card to trash"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards\?mid=\d{8}$|,
        "redirects to /cards after moving a card to trash"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card has been moved to trash",
        "shows success notification after moving a card to trash"
    );

    is(
        $schema->resultset("Card")->find(1)->in_trash,
        1,
        "has updated in_trash attribute"
    );

    reset_fixtures;
};

subtest "moving card to trash that is already in trash" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(4)->in_trash,
        1,
        "card is currently in trash"
    );

    $mech->get("/cards/4/movetotrash");

    $mech->header_is(
        "status",
        302,
        "redirects after moving card to trash"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards\?mid=\d{8}$|,
        "redirects to /cards after moving a card to trash"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card has been moved to trash",
        "shows success notification after moving a card to trash"
    );

    is(
        $schema->resultset("Card")->find(4)->in_trash,
        1,
        "card is still in trash"
    );

    reset_fixtures;
};

subtest "try to move another user's card to trash" => sub {
    login_mech;

    $mech->get("/cards/6/movetotrash");

    $mech->header_is(
        "Status",
        404,
        "has status 404 when trying to move another user's card to trash"
    );

    $mech->content_contains(
        "404 - Not Found",
        "Shows 'Not Found' message"
    );

    is(
        $schema->resultset("Card")->find(6)->in_trash,
        0,
        "card is still not in trash"
    );
}