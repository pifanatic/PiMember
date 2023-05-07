use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}



my $tx;

$mech->get("/trash/empty");

$mech->header_is(
    "Status",
    302,
    "redirects when accessing /trash/empty without login"
);

$mech->header_is(
    "Location",
    "http://localhost/login",
    "redirects to login when access /trash/empty without login"
);



login_mech;



$mech->get(
    "/trash/empty",
    "can GET /trash/empty when logged in"
);

$mech->header_is(
    "Status",
    302,
    "redirects when emptying trash"
);

$mech->header_like(
    "Location",
    qr|http://localhost/trash\?mid=\d{8}|,
    "redirects to trash"
);

$mech->get($mech->res->header("Location"));

$tx = prepare_html_tests;

$tx->like(
    '//div[@class="notification success"]',
    qr/Trash has been emptied/,
    "contains success message"
);

$tx->like(
    '//h1',
    qr/Trash/,
    "sub-header contains correct heading"
);

$tx->like(
    '//div[@class="sub-header-left"]',
    qr/0 cards total/,
    "sub-header contains correct number of cards"
);

$tx->not_ok(
    '//a[@href="http://localhost/trash/empty"]',
    "contains no link to empty trash"
);

$tx->is(
    'count(//div[@class="list-item"])',
    0,
    "contains no list-item elements (no cards remain in trash)"
);

$tx->not_ok(
    '//div[@class="list"]',
    "contains no card list"
);

$tx->like(
    '//div[@class="empty-list"]',
    qr/Trash is empty/,
    "contains empty list hint"
);

is(
    $mech->c->model("DB::Card")->search({
        in_trash => 1
    })->count,
    0,
    "no in_trash cards are left in database"
);

is(
    $mech->c->model("DB::Tag")->search({
        name => "tag_to_be_deleted"
    })->count,
    0,
    "unused tag has been deleted from database"
);
