use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "GET /cards/learn with no login" => sub {
    $mech->get("/cards/learn");

    $mech->header_is(
        "Status",
        302,
        "redirects when accessing /cards/learn without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when accessing /cards/learn without login"
    );
};

subtest "GET /cards/learn with login and due card" => sub {
    login_mech;

    $mech->get_ok(
        "/cards/learn",
        "can GET /cards/learn when logged in"
    );

    $tx = prepare_html_tests;

    $tx->ok(
        '//div[@class="sub-header-right"]/a[1]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/3",
                "correct href attribute"
            )
        },
        "contains link to view card"
    );

    $tx->ok(
        '//div[@class="sub-header-right"]/a[2]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/cards/3/edit",
                "correct href attribute"
            )
        },
        "contains link to edit card"
    );

    $tx->like(
        '//div[@id="front-text"]',
        qr|Test Card 3 <b>Frontside</b>|,
        "contains front side of due card"
    );

    $tx->like(
        '//div[@id="back-text"]',
        qr|Test Card 3 <b>Backside</b>|,
        "contains back side of due card"
    );

    $tx->ok(
        '//form[@id="learnForm"]/input',
        sub {
            is(
                $tx->node->getAttribute("value"),
                "3",
                "contains correct value"
            );
            is(
                $tx->node->getAttribute("hidden"),
                "",
                "input is hidden"
            );
        },
        "contains hidden input with card id"
    );

    $tx->ok(
        '//script[@src="http://localhost/static/js/learn.js"]',
        "contains script element to load learn.js"
    );
};

subtest "GET /cards/learn with no due card" => sub {
    login_mech;

    $schema->resultset("Card")->delete_all;

    $mech->get("/cards/learn");

    $tx = prepare_html_tests;

    $tx->like(
        '//div[@class="center-message"]',
        qr/You have learned all cards for today!/,
        "contains completion hint"
    );

    $tx->not_ok(
        '//div[@id="front-text"]',
        "does not contain front side"
    );

    $tx->not_ok(
        '//div[@id="back-text"]',
        "does not contain back side"
    );

    reset_fixtures;
};

subtest "POST /learn" => sub {
    login_mech;
    mock_time;

    subtest "with correct answer" => sub {
        my $updated_card;

        $mech->get("/cards/learn");

        $mech->form_id("learnForm");
        $mech->click_button(id => "answerCorrect");

        $mech->header_is(
            "Status",
            302,
            "has correct status"
        );

        $mech->header_is(
            "Location",
            "http://localhost/cards/learn",
            "should redirect to /cards/learn"
        );

        $updated_card = $schema->resultset("Card")->find(3);

        is(
            $updated_card->rating,
            7,
            "has increased the rating by 1"
        );

        is(
            $updated_card->correct_answers,
            3,
            "has increased correct_answers by 1"
        );

        is(
            $updated_card->wrong_answers,
            1,
            "has not changed wrong_answers"
        );

        is(
            $updated_card->last_seen,
            "2023-01-15T13:37:42",
            "has set last_seen to current time"
        );

        is(
            $updated_card->due,
            "2023-01-22T00:00:00",
            "has set due to current date + rating"
        );

        reset_fixtures;
    };

    subtest "with wrong answer" => sub {
        my $updated_card;

        $mech->get("/cards/learn");

        $mech->form_id("learnForm");
        $mech->click_button(id => "answerWrong");

        $mech->header_is(
            "Status",
            302,
            "has correct status"
        );

        $mech->header_is(
            "Location",
            "http://localhost/cards/learn",
            "should redirect to /cards/learn"
        );

        $updated_card = $schema->resultset("Card")->find(3);

        is(
            $updated_card->rating,
            0,
            "has set the rating to 0"
        );

        is(
            $updated_card->correct_answers,
            2,
            "has not changed correct_answers"
        );

        is(
            $updated_card->wrong_answers,
            2,
            "has increased wrong_answers by 1"
        );

        is(
            $updated_card->last_seen,
            "2023-01-15T13:37:42",
            "has set last_seen to current time"
        );

        is(
            $updated_card->due,
            "2023-01-15T00:00:00",
            "has set due to current date"
        );

        reset_fixtures;
    };

    restore_time;
};
