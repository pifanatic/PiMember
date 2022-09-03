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
