use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

login_mech;

$mech->get("/");

$mech->header_is(
    "Status",
    200,
    "GETting / with login is a success"
);

$mech->get("/logout");

$mech->header_is(
    "Status",
    302,
    "/logout redirects"
);

$mech->header_is(
    "Location",
    "http://localhost/login",
    "/logout redirects to /login"
);

$mech->get("/");

$mech->header_is(
    "Status",
    302,
    "GETting / after logout is now a redirect"
);

$mech->header_is(
    "Location",
    "http://localhost/login",
    "GETting / after logout redirects to /login"
);
