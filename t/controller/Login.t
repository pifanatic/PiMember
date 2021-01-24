use strict;
use warnings;
use Test::More;

BEGIN {
    $ENV{PIMEMBER_CONFIG_LOCAL_SUFFIX} = "testing";
}

eval "use Test::WWW::Mechanize::Catalyst 'PiMember'";
plan $@
    ? (skip_all => "Test::WWW::Mechanize::Catalyst required")
    : (tests => 15);

ok(my $mech = Test::WWW::Mechanize::Catalyst->new(max_redirect => 0),
    "Created mech object");



$mech->get_ok("/login");
$mech->content_contains("Sign in to PiMember");



$mech->submit_form_ok({
        fields      => {},
    }
);
$mech->content_contains("Username and password required.");



$mech->submit_form_ok({
        fields      => {
            password => "PASSWORD"
        },
    }
);
$mech->content_contains("Username and password required.");



$mech->submit_form_ok({
        fields      => {
            username => "USERNAME"
        },
    }
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
            username => "admin",
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
