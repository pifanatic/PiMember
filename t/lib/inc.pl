use strict;
use warnings;
use DBIx::Class::Fixtures;
use PiMember::Schema;
use vars qw/$schema $mech $fixtures/;
use Test::XPath;

BEGIN {
    $ENV{PIMEMBER_CONFIG_LOCAL_SUFFIX} = "testing";
}

use Test::WWW::Mechanize::Catalyst "PiMember";

my $TEST_DB_DIR = "t/lib/db/";
my $TEST_DB_NAME = "pimember.db";

unless (-d $TEST_DB_DIR) {
    mkdir $TEST_DB_DIR;
}

$mech = Test::WWW::Mechanize::Catalyst->new(max_redirect => 0);

$schema = PiMember::Schema->connect("dbi:SQLite:$TEST_DB_DIR$TEST_DB_NAME");
$schema->deploy({
    add_drop_table => 1,
});

$fixtures = DBIx::Class::Fixtures->new({
    config_dir => "t/lib/fixtures"
});

$fixtures->populate({
    directory => "t/lib/fixtures",
    schema    => $schema,
    no_deploy => 1
});

sub login_mech {
    $mech->cookie_jar->clear;

    $mech->get("/login");

    $mech->submit_form((
            fields      => {
                username => "<b>admin</b>",
                password => "admin"
            },
        )
    );
}

sub prepare_html_tests {
    Test::XPath->new(
        xml     => $mech->content,
        is_html => 1,
        options => {
            recover => 2
        }
    );
}

1;
