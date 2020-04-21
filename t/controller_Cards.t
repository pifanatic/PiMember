use strict;
use warnings;
use Test::More;

use Catalyst::Test "PiMember";
use PiMember::Controller::Cards;

ok(request("/cards")->is_success, "Request should succeed");

done_testing();
