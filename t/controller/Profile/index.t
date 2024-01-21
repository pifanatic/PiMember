use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

subtest "GET /profile without login" => sub {
    $mech->get("/profile");

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

subtest "GET /profile with login" => sub {
    my $tx;

    login_mech;

    $mech->get_ok(
        "/profile",
        "can GET /profile when logged in"
    );

    $tx = prepare_html_tests;

    $tx->like(
        "//h1",
        qr/Profile/,
        "sub-header contains correct heading"
    );

    $tx->ok(
        '//div[@class="sub-header-right"]/a',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/profile/edit",
                "correct href attribute"
            )
        },
        "contains link to edit profile page"
    );

    $tx->ok(
        '//section[@class="profile-username"]',
        "contains section for username"
    );

    $tx->like(
        '//section[@class="profile-username"]' .
            '/div[@class="profile-attribute-value"]',
        qr|<b>admin</b>|,
        "contains correct value for username"
    );

    $tx->ok(
        '//section[@class="profile-displayname"]',
        "contains section for displayname"
    );

    $tx->like(
        '//section[@class="profile-displayname"]' .
            '/div[@class="profile-attribute-value"]',
        qr|<b>Admin</b>|,
        "contains correct value for displayname"
    );

    $tx->ok(
        '//section[@class="profile-password"]',
        "contains section for password"
    );

    $tx->ok(
        '//a[@class="password-change-link"]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/password/change",
                "href is set correctly"
            );
        },
        "contains link to password change"
    );

    $tx->ok(
        '//section[@class="profile-mathjax"]',
        "contains section for mathjax"
    );

    $tx->like(
        '//section[@class="profile-mathjax"]' .
            '/div[@class="profile-attribute-value"]',
        qr/disabled/,
        "contains correct value when mathjax is disabled"
    );

    $tx->ok(
        '//section[@class="profile-max-rating"]',
        "contains section for max-rating"
    );

    $tx->like(
        '//section[@class="profile-max-rating"]' .
            '/div[@class="profile-attribute-value"]',
        qr/Unlimited/,
        "contains correct value when max_rating is 0"
    );
};

subtest "GET /profile with alternative user" => sub {
    my $tx;

    login_mech "second_user";

    $mech->get("/profile");

    $tx = prepare_html_tests;

    $tx->like(
        '//section[@class="profile-mathjax"]' .
            '/div[@class="profile-attribute-value"]',
        qr/enabled/,
        "contains correct value when mathjax is enabled"
    );

    $tx->like(
        '//section[@class="profile-max-rating"]' .
            '/div[@class="profile-attribute-value"]',
        qr/25/,
        "contains correct value when max_rating is 25"
    );
};
