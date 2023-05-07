use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}



my $tx;
my $card;
my $tag;

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
    '//script[@id="cardFormScript"]',
    sub {
        my $node = $tx->node;
        is(
            $node->getAttribute("type"),
            "module",
            "script is of type 'module'"
        );
        like(
            $node->getAttribute("src"),
            qr#http://localhost/static/js/cardForm\.js\?v=\d\.\d*#,
            "script has correct src attribute"
        );
    },
    "contains script to load cardForm.js"
);

#
# Tests for form submission
#

$mech->submit_form(
    form_id => "cardForm",
    fields => {
        frontside => "New Card Frontside",
        backside  => "New Card Backside",
        tags      => "tag_01 new_tag"
    }
);

$mech->header_is(
    "Status",
    302,
    "redirects after adding a new card"
);

$mech->header_like(
    "Location",
    qr|^http://localhost/cards/add\?mid=\d{8}$|,
    "redirects to the correct location after adding a new card"
);

$mech->get($mech->res->header("Location"));
$mech->content_contains(
    "New card has been created!",
    "shows success notification after adding a new card"
);

$card = $mech->c->model("DB::Card")->find({ frontside => "New Card Frontside" });
$tag  = $mech->c->model("DB::Tag")->find({ name => "new_tag" });

ok(
    $card,
    "created the new card in database"
);

is(
    $card->id,
    6,
    "set correct id for new card in database"
);

is(
    $card->frontside,
    "New Card Frontside",
    "set correct frontside for new card in database"
);

is(
    $card->backside,
    "New Card Backside",
    "set correct backside for new card in database"
);

is(
    $card->due,
    DateTime->today->iso8601,
    "set today as due date for new card in database"
);

is(
    $card->last_seen,
    undef,
    "set correct last_seen date for new card in database"
);

is(
    $card->created,
    DateTime->today->iso8601,
    "set correct created date for new card in database"
);

is(
    $card->rating,
    0,
    "set correct rating for new card in database"
);

is(
    $card->correct_answers,
    0,
    "set correct correct_answers for new card in database"
);

is(
    $card->wrong_answers,
    0,
    "set correct wrong_answers for new card in database"
);

is(
    $card->in_trash,
    0,
    "set correct in_trash for new card in database"
);

is(
    $card->user_id,
    1,
    "set correct user_id for new card in database"
);

ok(
    $tag,
    "created a new tag in database"
);

is(
    $tag->id,
    4,
    "set correct id for new tag in database"
);

is(
    $tag->name,
    "new_tag",
    "set correct name for new tag in database"
);

is(
    $tag->user_id,
    1,
    "set correct user_id for new tag in database"
);

is(
    $mech->c->model("DB::Tag")->search({ name => "tag_01" })->count,
    1,
    "did not create a new row in database for already existing tag"
);

ok(
    $mech->c->model("DB::CardsTag")->find({ card_id => 6, tag_id => 1 }),
    "created the correct cards_tag row for the first tag"
);

ok(
    $mech->c->model("DB::CardsTag")->find({ card_id => 6, tag_id => 4 }),
    "created the correct cards_tag row for the second tag"
);

$mech->submit_form(
    form_id => "cardForm",
    fields => {
        backside  => "New Card Backside",
        tags      => "tag_01 new_tag"
    }
);

$mech->header_is(
    "Status",
    302,
    "redirects after trying to add a new card without frontside"
);

$mech->header_like(
    "Location",
    qr|^http://localhost/cards/add\?mid=\d{8}$|,
    "redirects to the correct location"
);

$mech->get($mech->res->header("Location"));
$mech->content_contains(
    "Could not create card!",
    "shows error notification after trying to add a new card without frontside"
);

$mech->submit_form(
    form_id => "cardForm",
    fields => {
        frontside  => "New Card Frontside",
        tags       => "tag_01 new_tag"
    }
);

$mech->header_is(
    "Status",
    302,
    "redirects after trying to add a new card without backside"
);

$mech->header_like(
    "Location",
    qr|^http://localhost/cards/add\?mid=\d{8}$|,
    "redirects to the correct location"
);

$mech->get($mech->res->header("Location"));
$mech->content_contains(
    "Could not create card!",
    "shows error notification after trying to add a new card without backside"
);

$mech->submit_form(
    form_id => "cardForm",
    fields => {}
);

$mech->header_is(
    "Status",
    302,
    "redirects after trying to add a new card without any form data"
);

$mech->header_like(
    "Location",
    qr|^http://localhost/cards/add\?mid=\d{8}$|,
    "redirects to the correct location"
);

$mech->get($mech->res->header("Location"));
$mech->content_contains(
    "Could not create card!",
    "shows error notification when adding a new card without any form data"
);
