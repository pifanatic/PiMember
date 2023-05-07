use strict;
use warnings;
use DBIx::Class::Fixtures;
use vars qw/$schema $mech $fixtures/;
use Test::XPath;
use Test::MockTime;

BEGIN {
    $ENV{PIMEMBER_CONFIG_LOCAL_SUFFIX} = "testing";
    $ENV{TESTING} = 1;
}

use Test::WWW::Mechanize::Catalyst::WithContext "PiMember";

$mech = Test::WWW::Mechanize::Catalyst::WithContext->new(max_redirect => 0);
$mech->get("/");

$schema = $mech->c->model("DB")->schema;

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
