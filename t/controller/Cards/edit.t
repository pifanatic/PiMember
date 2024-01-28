use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

subtest "GET /cards/*/edit without login" => sub {
    $mech->get("/cards/1/edit");

    $mech->header_is(
        "Status",
        302,
        "redirects"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login"
    );
};

subtest "try to edit another user's card" => sub {
    login_mech;

    $mech->get("/cards/6/edit");

    $mech->header_is(
        "Status",
        404,
        "has status 404"
    );

    $mech->content_contains(
        "404 - Not Found",
        "has Not Found message"
    );
};

subtest "try to edit non-existing card" => sub {
    login_mech;

    $mech->get("/cards/66/edit");

    $mech->header_is(
        "Status",
        404,
        "has status 404"
    );

    $mech->content_contains(
        "404 - Not Found",
        "has Not Found message"
    );
};

subtest "GET /cards/*/edit" => sub {
    login_mech;

    $mech->get_ok(
        "/cards/1/edit",
        "can GET /cards/*/edit"
    );

    my $tx = prepare_html_tests;

    $tx->ok(
        '//div[@class="button-row"]/a[1]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/1",
                "correct href attribute"
            );

            like(
                $tx->node->textContent,
                qr/Cancel/,
                "contains correct text"
            );
        },
        "contains cancel link to view card"
    );

    $tx->like(
        '//textarea[@id="front-input"]',
        qr/Test Card 1 Frontside/,
        "contains frontside text"
    );

    $tx->like(
        '//textarea[@id="back-input"]',
        qr/Test Card 1 Backside/,
        "contains backside text"
    );

    $tx->ok(
        '//input[@id="tags"]',
        sub {
            is(
                $tx->node->getAttribute("value"),
                "tag_01 <span>tag_02</span>",
                "correct value"
            );
        },
        "contains input with tags"
    );

    $tx->ok(
        '//script[@id="cardFormScript"]',
        sub {
            like(
                $tx->node->getAttribute("src"),
                qr|^http://localhost/static/js/cardForm.js\?v=\d+\.\d+$|,
                "has source attribute with version"
            );
        },
        "contains script tag to load cardForm.js"
    );
};