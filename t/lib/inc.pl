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

$mech = Test::WWW::Mechanize::Catalyst->new(max_redirect => 0);

$schema = PiMember::Schema->connect("dbi:SQLite:t/lib/db/pimember.db");

$fixtures = DBIx::Class::Fixtures->new({
    config_dir => "t/lib/fixtures"
});

$fixtures->populate({
    directory => "t/lib/fixtures",
    schema    => $schema,
    no_deploy => 1
});

sub prepare_html_tests {
    Test::XPath->new(
        xml     => $mech->content,
        is_html => 1,
        options => {
            recover => 2
        }
    );
}

END {
    map { $schema->resultset($_)->delete_all; } $schema->sources;
}

1;
