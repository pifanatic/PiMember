use strict;
use warnings;
use Test::More;
use DBIx::Class::Fixtures;
use PiMember::Schema;

my $schema;
my $mech;
my $fixtures;

BEGIN {
    $ENV{PIMEMBER_CONFIG_LOCAL_SUFFIX} = "testing";
}

END {
    map { $schema->resultset($_)->delete_all; } $schema->sources;
}

eval "use Test::WWW::Mechanize::Catalyst 'PiMember'";
plan $@
    ? (skip_all => "Test::WWW::Mechanize::Catalyst required")
    : (tests => 3);

ok($mech = Test::WWW::Mechanize::Catalyst->new(max_redirect => 0),
    "Created mech object");

$schema = PiMember::Schema->connect("dbi:SQLite:t/lib/db/pimember.db");

$fixtures = DBIx::Class::Fixtures->new({
    config_dir => "t/lib/fixtures"
});

$fixtures->populate({
    directory => "t/lib/fixtures",
    schema    => $schema,
    no_deploy => 1
});



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
