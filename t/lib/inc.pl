use strict;
use warnings;
use DBIx::Class::Fixtures;
use vars qw/$schema $mech $fixtures/;
use Test::XPath;
use Test::MockTime;
use PiMember ();

BEGIN {
    $ENV{TESTING} = 1;

    $ENV{TZ} = "UTC";
    Test::MockTime::set_fixed_time("2023-01-15T13:37:42Z");
}

$schema = PiMember::Schema->connect({
    dsn            => 'dbi:SQLite::memory:',
    on_connect_do  => q{PRAGMA foreign_keys = ON},
    sqlite_unicode => 1
});
PiMember->model("DB")->schema($schema);

use Test::WWW::Mechanize::Catalyst "PiMember";

$mech = Test::WWW::Mechanize::Catalyst->new(max_redirect => 0);

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

1;
