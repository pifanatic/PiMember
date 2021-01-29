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
    : (tests => 15);

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
