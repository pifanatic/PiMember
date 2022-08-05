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
