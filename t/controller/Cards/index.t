use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}



my $tx;

$mech->get("/cards");

$mech->header_is(
    "Status",
    302,
    "redirects when accessing /cards without login"
);

$mech->header_is(
    "Location",
    "http://localhost/login",
    "redirects to login when access /cards without login"
);



$mech->get("/login");

$mech->submit_form((
        fields      => {
            username => "admin",
            password => "admin"
        },
    )
);



$mech->get_ok(
    "/cards",
    "can GET /cards when logged in"
);

$tx = prepare_html_tests;

$tx->like(
    '//div[@class="sub-header-title"]',
    qr/Cards/,
    "sub-header-title contains correct text"
);

$tx->like(
    '//div[@class="sub-header"]/span',
    qr/3 cards total/,
    "sub-header contains correct number of cards"
);

$tx->not_ok(
    '//a[@class="sub-header-link"]',
    "sub-header contains no .sub-header-links"
);

$tx->like(
    '//a[@href="http://localhost/cards/add"]',
    qr/Create card/,
    "contains link to create a new card"
);

$tx->is(
    'count(//div[@class="list-item"])',
    3,
    "contains three list-item elements (all that are not in trash)"
);

$tx->like(
    '//div[@card_id="1"]//div[@class="cell"][1]',
    qr/Test Card 1/,
    "contains title of first card"
);

$tx->like(
    '//div[@card_id="1"]//div[@class="cell"][2]',
    qr/Test Card 1 Frontside/,
    "contains frontside of first card"
);

$tx->like(
    '//div[@card_id="1"]//div[@class="cell"][3]',
    qr/Test Card 1 Backside/,
    "contains backside of first card"
);

$tx->like(
    '//div[@card_id="1"]//div[@class="cell tags"]//span[@class="tag"]' .
        '//a[@href="http://localhost/cards?tag=tag_01"]',
    qr/tag_01/,
    "contains first tag of first card"
);

$tx->like(
    '//div[@card_id="1"]//div[@class="cell tags"]//span[@class="tag"]' .
        '//a[@href="http://localhost/cards?tag=%3Cspan%3Etag_02%3C%2Fspan%3E"]',
    qr/<span>tag_02<\/span>/,
    "contains second tag of first card"
);

$tx->like(
    '//div[@card_id="2"]//div[@class="cell"][1]',
    qr/<span>Test Card 2<\/span>/,
    "contains title of second card"
);

$tx->like(
    '//div[@card_id="2"]//div[@class="cell"][2]',
    qr/<div>Test Card 2 Frontside<\/div>/,
    "contains frontside of second card"
);

$tx->like(
    '//div[@card_id="2"]//div[@class="cell"][3]',
    qr/<p>Test Card 2 Backside<\/p>/,
    "contains backside of second card"
);

$tx->like(
    '//div[@card_id="1"]//div[@class="cell tags"]//span[@class="tag"]' .
        '//a[@href="http://localhost/cards?tag=tag_01"]',
    qr/tag_01/,
    "contains tag of second card"
);

$tx->like(
    '//div[@card_id="3"]//div[@class="cell"][1]',
    qr/Test Card 3/,
    "contains title of third card"
);

$tx->like(
    '//div[@card_id="3"]//div[@class="cell"][2]',
    qr/Test Card 3 Frontside/,
    "contains frontside of third card"
);

$tx->like(
    '//div[@card_id="3"]//div[@class="cell"][3]',
    qr/Test Card 3 Backside/,
    "contains backside of third card"
);

$tx->not_ok(
    '//div[@card_id="3"]//div[@class="tags"]//tag',
    "contains no tags for third card"
);

$tx->not_ok(
    '//div[@class="empty-list"]',
    "does not contain empty list hint"
);



#
# Tests for the tag-filtered list
#

$mech->get_ok("/cards?tag=tag_01");

$tx = prepare_html_tests;

$tx->like(
    '//div[@class="sub-header-title"]',
    qr/tag_01/,
    "sub-header-title contains tag name"
);

$tx->like(
    '//a[@class="sub-header-link"][@href="http://localhost/cards"]',
    qr/See all cards/,
    "sub-header contains link to see the entire card list"
);

$tx->is(
    'count(//div[@class="list-item"])',
    2,
    "tag-filtered cards list contains two list-items"
);

$tx->ok(
    '//div[@card_id="1"]',
    "contains first card with the 'tag_01' tag"
);

$tx->ok(
    '//div[@card_id="2"]',
    "contains second card with the 'tag_01' tag"
);

$tx->not_ok(
    '//div[@card_id="3"]',
    "does not contain card without the 'tag_01' tag"
);


$mech->get_ok("/cards?tag=TAG_01");

$tx = prepare_html_tests;

$tx->like(
    '//div[@class="sub-header-title"]',
    qr/tag_01/,
    "sub-header-title contains tag name in lower-case"
);

$tx->is(
    'count(//div[@class="list-item"])',
    2,
    "tag-filtered cards list filters lower-case"
);


$mech->get_ok("/cards?tag=<span>tag_02</span>");

$tx = prepare_html_tests;

$tx->like(
    '//div[@class="sub-header-title"]',
    qr/<span>tag_02<\/span>/,
    "sub-header-title contains tag name with HTML entities escaped"
);


$mech->get_ok("/cards?tag=i_dont_exist");

$tx = prepare_html_tests;

$tx->like(
    '//div[@class="sub-header-title"]',
    qr/i_dont_exist/,
    "sub-header-title contains tag name even if tag does not exist"
);

$tx->not_ok(
    '//div[@class="list"]',
    "show no list when tag does not exist"
);

$tx->is(
    '//div[@class="empty-list"]',
    "No cards found",
    "contains empty list hint when tag does not exist"
);



#
# Tests for empty card list
#

$schema->resultset("Card")->delete_all;

$mech->get_ok("/cards");

$tx = prepare_html_tests;

$tx->like(
    '//div[@class="sub-header"]//span',
    qr/0 cards total/,
    "sub-header contains correct number of cards"
);

$tx->not_ok(
    '//div[@class="list"]',
    "contains no card list"
);

$tx->like(
    '//div[@class="empty-list"]',
    qr/No cards found/,
    "contains empty list hint"
);
