use strict;
use warnings;
use Test::More;

use Catalyst::Test "PiMember";

ok(
    request("/cards")->is_redirect,
    "Request should redirect"
);

is(
    request("/cards")->headers->{location},
    "http://localhost/login",
    "Request should redirect to /login"
);

done_testing();
