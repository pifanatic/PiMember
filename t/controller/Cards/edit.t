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

subtest "POST /cards/*/edit" => sub {
    my $edited_card;

    login_mech;

    $mech->get("/cards/1/edit");

    $mech->submit_form(
        form_id => "cardForm",
        fields => {
            frontside => "Test Card 1 Frontside Edited",
            backside  => "Test Card 1 Backside Edited",
            tags      => "tag_01 <span>tag_02</span> tag_edited"
        }
    );

    $mech->header_is(
        "Status",
        302,
        "redirects after editing a new card"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards/1\?mid=\d{8}$|,
        "redirects to the correct location after editing a card"
    );

    $edited_card = $schema->resultset("Card")->find(1);

    is(
        $edited_card->frontside,
        "Test Card 1 Frontside Edited",
        "has correctly edited frontside"
    );

    is(
        $edited_card->backside,
        "Test Card 1 Backside Edited",
        "has correctly edited backside"
    );

    is(
        ($edited_card->tags)[0]->name,
        "tag_01",
        "has left first tag intact"
    );

    is(
        ($edited_card->tags)[1]->name,
        "<span>tag_02</span>",
        "has left second tag intact"
    );

    is(
        ($edited_card->tags)[2]->name,
        "tag_edited",
        "has added a new tag"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card edited successfully!",
        "shows success notification after editing a card"
    );

    reset_fixtures;
};

subtest "POST /cards/*/edit to remove one tag" => sub {
    my $edited_card;

    login_mech;

    $mech->get("/cards/1/edit");

    $mech->submit_form(
        form_id => "cardForm",
        fields => {
            frontside => "Test Card 1 Frontside Edited",
            backside  => "Test Card 1 Backside Edited",
            tags      => "tag_01"
        }
    );

    $mech->header_is(
        "Status",
        302,
        "redirects after editing a new card"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards/1\?mid=\d{8}$|,
        "redirects to the correct location after editing a card"
    );

    $edited_card = $schema->resultset("Card")->find(1);

    is(
        $edited_card->tags,
        1,
        "card has only one tag left"
    );

    is(
        ($edited_card->tags)[0]->name,
        "tag_01",
        "has left correct tag intact"
    );

    is(
        $schema->resultset("Tag")->search({
            name => "<span>tag_02</span>" }
        )->count,
        0,
        "has removed unused tag"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card edited successfully!",
        "shows success notification after editing a card"
    );

    reset_fixtures;
};

subtest "POST /cards/*/edit to remove all tags" => sub {
    my $edited_card;

    login_mech;

    $mech->get("/cards/1/edit");

    $mech->submit_form(
        form_id => "cardForm",
        fields => {
            frontside => "Test Card 1 Frontside Edited",
            backside  => "Test Card 1 Backside Edited",
            tags      => ""
        }
    );

    $mech->header_is(
        "Status",
        302,
        "redirects after editing a new card"
    );

    $mech->header_like(
        "Location",
        qr|^http://localhost/cards/1\?mid=\d{8}$|,
        "redirects to the correct location after editing a card"
    );

    $edited_card = $schema->resultset("Card")->find(1);

    is(
        $edited_card->tags,
        0,
        "card has no tags left"
    );

    is(
        $schema->resultset("Tag")->search({
            name => "<span>tag_02</span>" }
        )->count,
        0,
        "has removed unused tag"
    );

    $mech->get($mech->res->header("Location"));
    $mech->content_contains(
        "Card edited successfully!",
        "shows success notification after editing a card"
    );

    reset_fixtures;
};

subtest "POST /cards/*/edit without frontside" => sub {
    my $edited_card;

    login_mech;

    $mech->get("/cards/1/edit");

    $mech->submit_form(
        form_id => "cardForm",
        fields => {
            frontside => "",
            backside  => "Test Card 1 Backside Edited",
            tags      => "tag_01 <span>tag_02</span>"
        }
    );

    $mech->header_is(
        "Status",
        400,
        "editing a new card without frontside is a Bad Request"
    );

    $edited_card = $schema->resultset("Card")->find(1);

    is(
        $edited_card->frontside,
        "Test Card 1 Frontside",
        "has left original frontside"
    );

    $mech->content_contains(
        "Could not edit card!",
        "shows error notification after editing a card without frontside"
    );

    reset_fixtures;
};

subtest "POST /cards/*/edit without backside" => sub {
    my $edited_card;

    login_mech;

    $mech->get("/cards/1/edit");

    $mech->submit_form(
        form_id => "cardForm",
        fields => {
            frontside => "Test Card 1 Frontside",
            backside  => "",
            tags      => "tag_01 <span>tag_02</span>"
        }
    );

    $mech->header_is(
        "Status",
        400,
        "editing a card without backside is a Bad Request"
    );

    $edited_card = $schema->resultset("Card")->find(1);

    is(
        $edited_card->backside,
        "Test Card 1 Backside",
        "has left original backside"
    );

    $mech->content_contains(
        "Could not edit card!",
        "shows error notification after editing a card without backside"
    );

    reset_fixtures;
};