use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

subtest "GET /password/change without login" => sub {
    $mech->get("/password/change");

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

subtest "GET /password/change with login" => sub {
    my $tx;

    login_mech;

    $mech->get_ok(
        "/password/change",
        "is a success"
    );

    $tx = prepare_html_tests;

    $tx->like(
        '//div[@class="sub-header"]/h1',
        qr/Change password/,
        "contains correct heading"
    );

    $tx->ok(
        '//div[@class="sub-header-left"]/a',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/profile",
                "correct href attribute"
            )
        },
        "contains link back to profile page"
    );

    $tx->ok(
        '//input[@id="old_password"]',
        sub {
            is(
                $tx->node->getAttribute("type"),
                "password",
                "has correct type"
            );

            ok(
                $tx->node->hasAttribute("required"),
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "old_password",
                "has correct name"
            );
        },
        "contains input for old password"
    );

    $tx->ok(
        '//input[@id="new_password"]',
        sub {
            is(
                $tx->node->getAttribute("type"),
                "password",
                "has correct type"
            );

            ok(
                $tx->node->hasAttribute("required"),
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "new_password",
                "has correct name"
            );

            is(
                $tx->node->getAttribute("minlength"),
                "10",
                "has correct minlength"
            );
        },
        "contains input for new password"
    );

    $tx->ok(
        '//input[@id="new_password_repeat"]',
        sub {
            is(
                $tx->node->getAttribute("type"),
                "password",
                "has correct type"
            );

            ok(
                $tx->node->hasAttribute("required"),
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "new_password_repeat",
                "has correct name"
            );

            is(
                $tx->node->getAttribute("minlength"),
                "10",
                "has correct minlength"
            );
        },
        "contains input for new password repeat"
    );

    $tx->ok(
        '//div[@class="button-row"]//a[@class="btn btn-secondary"]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/profile",
                "link has correct href"
            );
        },
        "contains button back to profile"
    );
};
