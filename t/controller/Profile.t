use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../lib/inc.pl";
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
};