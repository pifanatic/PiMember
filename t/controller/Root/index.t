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
