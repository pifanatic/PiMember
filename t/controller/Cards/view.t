use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "view card without login" => sub {
    $mech->get("/cards/1");

    $mech->header_is(
        "Status",
        302,
        "is a redirect"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login"
    );
};

subtest "view card" => sub {
    login_mech;

    $mech->get_ok(
        "/cards/1",
        "can GET /cards/1"
    );

    $tx = prepare_html_tests;

    $tx->ok(
        '//div[@class="sub-header-left"]/a[@class="icon-button"]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards"
            );
        },
        "has link back to cards list"
    );

    $tx->ok(
        '//div[@class="sub-header-right"]/a[@class="icon-button"][1]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/1/deactivate"
            );
        },
        "has link to deactivate card"
    );

    $tx->ok(
        '//div[@class="sub-header-right"]/a[@class="icon-button"][2]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/1/movetotrash"
            );
        },
        "has link to move card to trash"
    );

    $tx->ok(
        '//div[@class="sub-header-right"]/a[@title="Edit"]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/1/edit"
            );
        },
        "has link to edit card"
    );

    $tx->like(
        '//div[@id="front-text"]',
        qr/Test Card 1 Frontside/,
        "contains frontside text"
    );

    $tx->like(
        '//div[@id="back-text"]',
        qr/Test Card 1 Backside/,
        "contains backside text"
    );

    $tx->like(
        '//div[@id="tags"]',
        qr/tag_01\s*<span>tag_02<\/span>/,
        "contains tags"
    );


    $tx->like(
        '//span[@id="created-item"]',
        qr/01\.01\.2021/,
        "contains creation date in correct format"
    );

    $tx->like(
        '//span[@id="last-learned-item"]',
        qr/01\.01\.2021/,
        "contains last learned date in correct format"
    );

    $tx->like(
        '//span[@id="due-item"]',
        qr/01\.01\.2021/,
        "contains due date in correct format"
    );

    $tx->like(
        '//span[@id="success-item"]',
        qr/2 of 3\s*\(66 %\)/,
        "contains success rate"
    );

    $tx->like(
        '//span[@id="rating-item"]',
        qr/0/,
        "contains rating"
    );

    $tx->like(
        '//span[@id="status-item"]',
        qr/ACTIVE/,
        "contains status 'ACTIVE'"
    );

    $tx->ok(
        '//script[@id="viewCardScript"]',
        sub {
            like(
                $tx->node->getAttribute("src"),
                qr|http://localhost/static/js/view\.js\?v=\d\.\d*|,
                "script has correct src attribute"
            );
        },
        "contains script to load view.js"
    );
};

subtest "view card in trash" => sub {
    login_mech;

    $mech->get_ok(
        "/cards/4",
        "can GET /cards/4"
    );

    $tx = prepare_html_tests;

    $tx->ok(
        '//div[@class="sub-header-left"]/a[@class="icon-button"]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/trash"
            );
        },
        "has link back to trash"
    );

    $tx->ok(
        '//div[@class="sub-header-right"]/a[@class="icon-button"]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/4/restore"
            );
        },
        "has link to restore card"
    );

    $tx->ok(
        '//div[@class="sub-header-right"]/a[@title="Delete"]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/4/delete"
            );
        },
        "has link to delete card permanently"
    );

    $tx->like(
        '//span[@id="status-item"]',
        qr/IN TRASH/,
        "contains status 'IN TRASH'"
    );
};

subtest "view cards with no tags" => sub {
    $mech->get("/cards/3");

    $tx = prepare_html_tests;

    $tx->like(
        '//div[@id="tags"]',
        qr/None/,
        "contains text for no tags"
    );
};

subtest "view cards with success rate 0 of 0" => sub {
    $schema->resultset("Card")->find(1)->update({
        correct_answers => 0,
        wrong_answers   => 0
    });

    $mech->get("/cards/1");

    $tx = prepare_html_tests;

    $tx->like(
        '//span[@id="success-item"]',
        qr/0 of 0\s*\(0 %\)/,
        "contains correct success item"
    );
};

subtest "view inactive card" => sub {
    $mech->get("/cards/8");

    $tx = prepare_html_tests;

    $tx->like(
        '//span[@id="status-item"]',
        qr/INACTIVE/,
        "contains status 'INACTIVE'"
    );
};