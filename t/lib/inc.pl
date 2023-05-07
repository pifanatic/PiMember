use strict;
use warnings;
use DBIx::Class::Fixtures;
use PiMember::Schema;
use vars qw/$schema $mech $fixtures/;
use Test::XPath;
use Test::MockTime;

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

$fixtures = DBIx::Class::Fixtures->new({
    config_dir => "t/lib/fixtures"
});

reset_fixtures();

sub reset_fixtures {
    $schema->deploy({
        add_drop_table => 1,
    });

    $fixtures->populate({
        directory => "t/lib/fixtures",
        schema    => $schema,
        no_deploy => 1
    });
}

sub login_mech {
    my $username = shift || "<b>admin</b>";

    $mech->cookie_jar->clear;

    $mech->get("/login");

    $mech->submit_form((
            fields      => {
                username => $username,
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

sub mock_time {
    $ENV{TZ} = "UTC";
    Test::MockTime::set_fixed_time("2023-01-15T13:37:42Z");
}

sub restore_time {
    delete $ENV{TZ};
    Test::MockTime::restore;
}

1;
