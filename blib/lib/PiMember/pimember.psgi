use strict;
use warnings;

use PiMember;

my $app = PiMember->apply_default_middlewares(PiMember->psgi_app);
$app;

