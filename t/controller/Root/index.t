use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

subtest "accessing / without login" => sub {
    $mech->get("/");

    $mech->header_is(
        "Status",
        302,
        "should redirect"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "should redirect to /login"
    );
};

subtest "accessing / with login" => sub {
    my $tx;

    login_mech;

    $mech->get_ok("/");

    $tx = prepare_html_tests;

    $tx->like(
        '//div[@class="sub-header"]/h1',
        qr/Welcome to PiMember/,
        "should contain welcome message"
    );

    $tx->ok(
        '//button[@class="learn-button btn btn-primary"]',
        sub {
            my $node = $tx->node;

            like(
                $node->textContent,
                qr/Start learning/,
                "contains correct text"
            );

            is(
                $node->getAttribute("onclick"),
                "window.location='http://localhost/cards/learn'",
                "has correct onlick action"
            );
        },
        "should contain button to start learning"
    );

    $tx->not_ok(
        '//script[@id="setup-mathjax"]',
        "should not contain script to setup mathjax"
    );

    $tx->not_ok(
        '//script[@id="load-mathjax"]',
        "should not contain script to load mathjax"
    );

    subtest "with mathjax enabled" => sub {
        login_mech "second_user";

        $mech->get_ok("/");

        $tx = prepare_html_tests;

        $tx->ok(
            '//script[@id="setup-mathjax"]',
            "should contain script to setup mathjax"
        );

        $tx->ok(
            '//script[@id="load-mathjax"]',
            "should contain script to load mathjax"
        );
    };
};

subtest "accessing /login with login" => sub {
    login_mech;

    $mech->get("/login");

    $mech->header_is(
        "Status",
        302,
        "should redirect"
    );

    $mech->header_is(
        "Location",
        "http://localhost/",
        "should redirect to /"
    );
};

subtest "accessing not_existing page with login" => sub {
    login_mech;

    $mech->get("/i_do_not_exist");

    $mech->header_is(
        "Status",
        404,
        "has Not Found status"
    );

    $mech->content_contains(
        "404 - Not Found",
        "contains Not Found hint"
    );
};

subtest "accessing any path without any user in database" => sub {
    $schema->resultset("User")->delete_all;

    $mech->get("/cards");

    $mech->header_is(
        "Status",
        302,
        "redirects"
    );

    $mech->header_is(
        "Location",
        "http://localhost/setup",
        "redirects to /setup"
    );

    reset_fixtures;
};

subtest "provoking an error" => sub {
    $mech->get("/error");

    $mech->header_is(
        "Status",
        500,
        "has status 500"
    );

    $mech->content_contains(
        "500 - Internal Server Error",
        "contains error message"
    );
};