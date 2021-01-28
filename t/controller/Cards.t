use strict;
use warnings;
use Test::More;

BEGIN {
    $ENV{PIMEMBER_CONFIG_LOCAL_SUFFIX} = "testing";
}

eval "use Test::WWW::Mechanize::Catalyst 'PiMember'";
plan $@
    ? (skip_all => "Test::WWW::Mechanize::Catalyst required")
    : (tests => 3);

ok(my $mech = Test::WWW::Mechanize::Catalyst->new(max_redirect => 0),
    "Created mech object");


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
