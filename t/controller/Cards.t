use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../lib/inc.pl";
}



$mech->get("/cards");

$mech->header_is(
    "Status",
    302,
    "redirects when accessing /cards without login"
);

$mech->header_is(
    "Location",
    "http://localhost/login",
    "redirects to login when access /cards without login"
);
