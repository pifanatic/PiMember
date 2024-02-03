use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "search without login" => sub {
    $mech->get("/cards/search");

    $mech->header_is(
        "Status",
        302,
        "redirects when accessing /cards/search without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when access /cards/search without login"
    );
};

subtest "search without parameter" => sub {
    login_mech;

    $mech->get_ok("/cards/search");

    $tx = prepare_html_tests;

    $tx->like(
        '//span[@class="sub-header-left"]',
        qr/0 cards found for ""/,
        "sub-header contains correct text"
    );

    $tx->like(
        '//div[@class="empty-list"]',
        qr/No cards found/,
        "contains empty list message"
    );

    $tx->ok(
        '//script[@src="http://localhost/static/js/search.js"]',
        "contains search script"
    );
};

subtest "search for text that does not exist" => sub {
    login_mech;

    $mech->get_ok("/cards/search?q=I_DONT_EXIST");

    $tx = prepare_html_tests;

    $tx->like(
        '//span[@class="sub-header-left"]',
        qr/0 cards found for "I_DONT_EXIST"/,
        "sub-header contains correct text"
    );

    $tx->like(
        '//div[@class="empty-list"]',
        qr/No cards found/,
        "contains empty list message"
    );

    $tx->ok(
        '//script[@src="http://localhost/static/js/search.js"]',
        "contains search script"
    );
};

subtest "search for text on frontside" => sub {
    login_mech;

    $mech->get_ok("/cards/search?q=Frontside");

    $tx = prepare_html_tests;

    $tx->like(
        '//span[@class="sub-header-left"]',
        qr/4 cards found for "Frontside"/,
        "sub-header contains correct text"
    );

    $tx->is(
        'count(//div[@class="list-item"])',
        4,
        "card list should have 4 elements"
    );

    $tx->like(
        '//div[@class="list-item"][1]//a[1]',
        qr/Test Card 1 Frontside/,
        "contains first matching card"
    );

    $tx->like(
        '//div[@class="list-item"][2]//a[1]',
        qr/<div>Test Card 2 Frontside<\/div>/,
        "contains second matching card"
    );

    $tx->like(
        '//div[@class="list-item"][3]//a[1]',
        qr/Test Card 3 <b>Frontside<\/b>/,
        "contains third matching card"
    );

    $tx->like(
        '//div[@class="list-item"][4]//a[1]',
        qr/Test Card 8 Frontside/,
        "contains fourth matching card"
    );
};

subtest "search for text on frontside case-insensitively" => sub {
    login_mech;

    $mech->get_ok("/cards/search?q=FRONTSIDE");

    $tx = prepare_html_tests;

    $tx->like(
        '//span[@class="sub-header-left"]',
        qr/4 cards found for "FRONTSIDE"/,
        "sub-header contains correct text"
    );

    $tx->is(
        'count(//div[@class="list-item"])',
        4,
        "card list should have 4 elements"
    );

    $tx->like(
        '//div[@class="list-item"][1]//a[1]',
        qr/Test Card 1 Frontside/,
        "contains first matching card"
    );

    $tx->like(
        '//div[@class="list-item"][2]//a[1]',
        qr/<div>Test Card 2 Frontside<\/div>/,
        "contains second matching card"
    );

    $tx->like(
        '//div[@class="list-item"][3]//a[1]',
        qr/Test Card 3 <b>Frontside<\/b>/,
        "contains third matching card"
    );

    $tx->like(
        '//div[@class="list-item"][4]//a[1]',
        qr/Test Card 8 Frontside/,
        "contains fourth matching card"
    );
};

subtest "search for text on backside" => sub {
    login_mech;

    $mech->get_ok("/cards/search?q=Backside");

    $tx = prepare_html_tests;

    $tx->like(
        '//span[@class="sub-header-left"]',
        qr/4 cards found for "Backside"/,
        "sub-header contains correct text"
    );

    $tx->is(
        'count(//div[@class="list-item"])',
        4,
        "card list should have 4 elements"
    );

    $tx->like(
        '//div[@class="list-item"][1]//a[2]',
        qr/Test Card 1 Backside/,
        "contains first matching card"
    );

    $tx->like(
        '//div[@class="list-item"][2]//a[2]',
        qr/<p>Test Card 2 Backside<\/p>/,
        "contains second matching card"
    );

    $tx->like(
        '//div[@class="list-item"][3]//a[2]',
        qr/Test Card 3 <b>Backside<\/b>/,
        "contains third matching card"
    );

    $tx->like(
        '//div[@class="list-item"][4]//a[2]',
        qr/Test Card 8 Backside/,
        "contains fourth matching card"
    );
};

subtest "search for text on Backside case-insensitively" => sub {
    login_mech;

    $mech->get_ok("/cards/search?q=BACKSIDE");

    $tx = prepare_html_tests;

    $tx->like(
        '//span[@class="sub-header-left"]',
        qr/4 cards found for "BACKSIDE"/,
        "sub-header contains correct text"
    );

    $tx->is(
        'count(//div[@class="list-item"])',
        4,
        "card list should have 4 elements"
    );

    $tx->like(
        '//div[@class="list-item"][1]//a[2]',
        qr/Test Card 1 Backside/,
        "contains first matching card"
    );

    $tx->like(
        '//div[@class="list-item"][2]//a[2]',
        qr/<p>Test Card 2 Backside<\/p>/,
        "contains second matching card"
    );

    $tx->like(
        '//div[@class="list-item"][3]//a[2]',
        qr/Test Card 3 <b>Backside<\/b>/,
        "contains third matching card"
    );

    $tx->like(
        '//div[@class="list-item"][4]//a[2]',
        qr/Test Card 8 Backside/,
        "contains fourth matching card"
    );
};