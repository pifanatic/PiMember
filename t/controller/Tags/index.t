use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "GET /tags without login" => sub {
    $mech->get("/tags");

    $mech->header_is(
        "Status",
        302,
        "redirects"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to /login"
    );
};

subtest "GET /tags with tags existing" => sub {
    login_mech;

    $mech->get_ok(
        "/tags",
        "can GET /tags"
    );

    $tx = prepare_html_tests;

    $tx->like(
        '//div[@class="sub-header-left"]',
        qr/3 tags total/,
        "contains text with correct number of tags"
    );

    $tx->like(
        '//div[@class="list-item"][1]/div[@class="cell tag-cell"]',
        qr/tag_01/,
        "contains text of first tag"
    );

    $tx->like(
        '//div[@class="list-item"][1]/div[@class="cell"][1]',
        qr/3/,
        "contains amount of first tag"
    );

    $tx->like(
        '//div[@class="list-item"][1]/div[@class="cell"][2]',
        qr/2/,
        "contains number of due cards with first tag"
    );

    $tx->ok(
        '//div[@class="list-item"][1]/div[@class="cell"][3]/a',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/learn?tag=tag_01",
                "contains correct href"
            );
        },
        "contains link to learn first tag"
    );

    $tx->like(
        '//div[@class="list-item"][2]/div[@class="cell tag-cell"]',
        qr/tag_to_be_deleted/,
        "contains text of second tag"
    );

    $tx->like(
        '//div[@class="list-item"][2]/div[@class="cell"][1]',
        qr/1/,
        "contains amount of second tag"
    );

    $tx->like(
        '//div[@class="list-item"][2]/div[@class="cell"][2]',
        qr/0/,
        "contains number of due cards with second tag"
    );

    $tx->like(
        '//div[@class="list-item"][2]/div[@class="cell"][3]',
        qr/^\s*$/,
        "contains no link to learn second tag (no cards are due)"
    );

    $tx->like(
        '//div[@class="list-item"][3]/div[@class="cell tag-cell"]',
        qr/<span>tag_02<\/span>/,
        "contains text of third tag"
    );

    $tx->like(
        '//div[@class="list-item"][3]/div[@class="cell"][1]',
        qr/1/,
        "contains amount of third tag"
    );

    $tx->like(
        '//div[@class="list-item"][3]/div[@class="cell"][2]',
        qr/1/,
        "contains number of due cards with third tag"
    );

    $tx->ok(
        '//div[@class="list-item"][3]/div[@class="cell"][3]/a',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/learn?" .
                "tag=%3Cspan%3Etag_02%3C%2Fspan%3E",
                "contains correct href"
            );
        },
        "contains link to learn third tag"
    );
};

subtest "GET /tags without any tags" => sub {
    $schema->resultset("Tag")->delete_all;

    $mech->get_ok(
        "/tags",
        "can GET /tags"
    );

    $tx = prepare_html_tests;

    $tx->like(
        '//div[@class="sub-header-left"]',
        qr/0 tags total/,
        "contains text with correct number of tags"
    );

    $tx->like(
        '//div[@class="empty-list"]',
        qr/No tags found/,
        "contains 'no tags' hint"
    );

    reset_fixtures;
}