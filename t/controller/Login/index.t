use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}



$mech->get_ok("/login");
$mech->content_contains("Sign in to PiMember");



$mech->submit_form((
        fields      => {},
    )
);
$mech->header_is(
    "Status",
    400,
    "no form-data is a Bad Request"
);
$mech->content_contains("Username and password required.");



$mech->submit_form((
        fields      => {
            password => "PASSWORD"
        },
    )
);
$mech->header_is(
    "Status",
    400,
    "no username is a Bad Request"
);
$mech->content_contains("Username and password required.");



$mech->submit_form((
        fields      => {
            username => "USERNAME"
        },
    )
);
$mech->header_is(
    "Status",
    400,
    "no password is a Bad Request"
);
$mech->content_contains("Username and password required.");



$mech->submit_form_ok({
        fields      => {
            username => "USERNAME",
            password => "PASSWORD"
        },
    }
);
$mech->content_contains("Incorrect username or password.");



$mech->submit_form((
        fields      => {
            username => "<b>admin</b>",
            password => "admin"
        },
    )
);

$mech->header_is(
    "Status",
    302,
    "redirects after successful login"
);

$mech->header_is(
    "Location",
    "http://localhost/",
    "redirects to '/' after successful login"
);



$mech->get("/login");

$mech->header_is(
    "Status",
    302,
    "redirects on GET /login when already logged in"
);

$mech->header_is(
    "Location",
    "http://localhost/",
    "redirects to '/'"
);
