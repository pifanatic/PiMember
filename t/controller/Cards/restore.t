use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "restoring a card with no login" => sub {
    $mech->get("/cards/1/restore");

    $mech->header_is(
        "Status",
        302,
        "redirects when restoring a card without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when restoring a card"
    );
};

subtest "restoring a card" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(4)->in_trash,
        1,
        "card is currently in trash"
    );

    $mech->get("/cards/4/restore");

    $mech->header_is(
        "status",
        302,
        "redirects after restoring"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/trash\?mid=\d{8}$|,
        "redirects to /trash after restoring a card"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card has been restored",
        "shows success notification after restoring a card"
    );

    is(
        $schema->resultset("Card")->find(4)->in_trash,
        0,
        "has updated in_trash attribute"
    );

    reset_fixtures;
};

subtest "restoring a card that is not in trash" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(1)->in_trash,
        0,
        "card is currently not in trash"
    );

    $mech->get("/cards/1/restore");

    $mech->header_is(
        "status",
        302,
        "redirects after restoring"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards\?mid=\d{8}$|,
        "redirects to /cards after restoring a non trash card"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Could not restore card",
        "shows error notification after restoring non trash card"
    );

    is(
        $schema->resultset("Card")->find(1)->in_trash,
        0,
        "card is still not in trash"
    );

    reset_fixtures;
};

subtest "try to restore another user's card" => sub {
    login_mech;

    $mech->get("/cards/7/movetotrash");

    $mech->header_is(
        "Status",
        404,
        "has status 404 when trying to restore another user's card"
    );

    $mech->content_contains(
        "404 - Not Found",
        "Shows 'Not Found' message"
    );

    is(
        $schema->resultset("Card")->find(7)->in_trash,
        1,
        "card is still in trash"
    );
};

subtest "try to restore another user's card that is not in trash" => sub {
    login_mech;

    is(
        $schema->resultset("Card")->find(6)->in_trash,
        0,
        "card is not in trash"
    );

    $mech->get("/cards/6/movetotrash");

    $mech->header_is(
        "Status",
        404,
        "has status 404 when trying to restore another user's card"
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
};