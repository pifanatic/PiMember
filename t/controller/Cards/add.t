use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}



my $tx;

$mech->get("/cards/add");

$mech->header_is(
    "Status",
    302,
    "redirects when accessing /cards/add without login"
);

$mech->header_is(
    "Location",
    "http://localhost/login",
    "redirects to login when access /cards/add without login"
);

login_mech;



$mech->get_ok(
    "/cards/add",
    "can GET /cards/add when logged in"
);

$tx = prepare_html_tests;

$tx->like(
    '//h1',
    qr/Add a new card/,
    "contains correct heading"
);

$tx->ok(
    '//form[@id="cardForm"][@method="post"]',
    "contains correct form declaration"
);

$tx->ok(
    '//textarea[@id="front-input"]',
    sub {
        my $node = $tx->node;

        is(
            $node->getAttribute("name"),
            "frontside",
            "textarea for frontside has correct name"
        );

        is(
            $node->getAttribute("rows"),
            "10",
            "textarea for frontside has correct number of rows"
        );

        is(
            $node->getAttribute("placeholder"),
            "Enter frontside text...",
            "textarea for frontside has correct placeholder"
        );

        is(
            $node->getAttribute("required"),
            "",
            "textarea for frontside is required"
        );

        is(
            $node->textContent,
            "",
            "textarea for frontside is empty"
        );
    },
    "contains frontside input element with correct attributes"
);

$tx->ok(
    '//textarea[@id="back-input"]',
    sub {
        my $node = $tx->node;

        is(
            $node->getAttribute("name"),
            "backside",
            "correct name"
        );

        is(
            $node->getAttribute("rows"),
            "10",
            "correct number of rows"
        );

        is(
            $node->getAttribute("placeholder"),
            "Enter backside text...",
            "correct placeholder"
        );

        is(
            $node->getAttribute("required"),
            "",
            "is required"
        );

        is(
            $node->textContent,
            "",
            "is empty"
        );
    },
    "contains backside input element with correct attributes"
);

$tx->ok(
    '//input[@id="tags"]',
    sub {
        my $node = $tx->node;
        is(
            $node->getAttribute("name"),
            "tags",
            "correct name"
        );

        is(
            $node->getAttribute("value"),
            "",
            "value is empty"
        );
    },
    "contains tags input element with correct attributes"
);

$tx->like(
    '//form[@id="cardForm"]//button',
    qr/Create/,
    "contains submit button with correct text"
);

$tx->ok(
    '//script[@src="http://localhost/static/js/cardForm.js"][@type="module"]',
    "contains script to load cardForm.js"
);
