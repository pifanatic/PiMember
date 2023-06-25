use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}



my $tx;

$mech->get("/trash");

$mech->header_is(
    "Status",
    302,
    "redirects when accessing /trash without login"
);

$mech->header_is(
    "Location",
    "http://localhost/login",
    "redirects to login when access /trash without login"
);



login_mech;



$mech->get_ok(
    "/trash",
    "can GET /trash when logged in"
);

$tx = prepare_html_tests;

$tx->like(
    '//h1',
    qr/Trash/,
    "sub-header contains correct heading"
);

$tx->like(
    '//div[@class="sub-header-left"]',
    qr/2 cards total/,
    "sub-header contains correct number of cards"
);

$tx->like(
    '//a[@href="http://localhost/trash/empty"]',
    qr/Empty trash/,
    "contains link to empty trash"
);

$tx->is(
    'count(//div[@class="list-item"])',
    2,
    "contains three list-item elements (all that are in trash)"
);

$tx->ok(
    '//div[@class="list-item"][1]//a[@class="cell"][1]',
    sub {
        like(
            $tx->node->textContent,
            qr/Test Card 4 Frontside/,
            "correct text content"
        );
        is(
            $tx->node->getAttribute("href"),
            "http://localhost/cards/4",
            "correct href"
        );
    },
    "first frontside cell has correct attributes"
);

$tx->ok(
    '//div[@class="list-item"][1]//a[@class="cell"][2]',
    sub {
        like(
            $tx->node->textContent,
            qr/Test Card 4 Backside/,
            "correct text content"
        );
        is(
            $tx->node->getAttribute("href"),
            "http://localhost/cards/4",
            "correct href"
        );
    },
    "first backside cell has correct attributes"
);

$tx->ok(
    '//div[@class="list-item"][2]//a[@class="cell"][1]',
    sub {
        like(
            $tx->node->textContent,
            qr/Test Card 5 Frontside/,
            "correct text content"
        );
        is(
            $tx->node->getAttribute("href"),
            "http://localhost/cards/5",
            "correct href"
        );
    },
    "second frontside cell has correct attributes"
);

$tx->ok(
    '//div[@class="list-item"][2]//a[@class="cell"][2]',
    sub {
        like(
            $tx->node->textContent,
            qr/Test Card 5 Backside/,
            "correct text content"
        );
        is(
            $tx->node->getAttribute("href"),
            "http://localhost/cards/5",
            "correct href"
        );
    },
    "second backside cell has correct attributes"
);

$tx->not_ok(
    '//div[@class="empty-list"]',
    "does not contain empty list hint"
);

#
# Tests for empty Trash
#

$schema->resultset("Card")->delete_all;

$mech->get_ok("/trash");

$tx = prepare_html_tests;

$tx->like(
    '//div[@class="sub-header-left"]',
    qr/0 cards total/,
    "sub-header contains correct number of cards"
);

$tx->not_ok(
    '//div[@class="list"]',
    "contains no card list"
);

$tx->not_ok(
    '//a[@href="http://localhost/trash/empty"]',
    "contains no link to empty trash"
);

$tx->like(
    '//div[@class="empty-list"]',
    qr/Trash is empty/,
    "contains empty list hint"
);
