use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "GET /profile/edit with no login" => sub {
    $mech->get("/profile/edit");

    $mech->header_is(
        "Status",
        302,
        "redirects when accessing /profile/edit without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when accessing /profile/edit without login"
    );
};

subtest "GET /profile/edit with login" => sub {
    login_mech;

    $mech->get_ok(
        "/profile/edit",
        "can GET /profile/edit when logged in"
    );

    $tx = prepare_html_tests;

    $tx->like(
        "//h1",
        qr/Edit Profile/,
        "sub-header contains correct heading"
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
        '//section[@class="profile-username"]',
        "contains section for username"
    );

    $tx->ok(
        '//section[@class="profile-username"]/input',
        sub {
            is(
                $tx->node->getAttribute("value"),
                "<b>admin</b>",
                "username input has correct value"
            );
        },
        "contains input for username"
    );

    $tx->ok(
        '//section[@class="profile-displayname"]',
        "contains section for displayname"
    );

    $tx->ok(
        '//section[@class="profile-displayname"]/input',
        sub {
            is(
                $tx->node->getAttribute("value"),
                "<b>Admin</b>",
                "displayname input has correct value"
            );
        },
        "contains input for displayname"
    );
};
