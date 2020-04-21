#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Catalyst::Test "PiMember";

# redirecting when not logged in
ok(
    request("/")->is_redirect,
    "Request should redirect"
);

is(
    request("/")->headers->{location},
    "http://localhost/login",
    "Request should redirect to /login"
);

done_testing();
