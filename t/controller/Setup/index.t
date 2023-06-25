use strict;
use warnings;
use FindBin;
use Test::More "no_plan";
use Digest::SHA qw/ sha512_base64 /;

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

subtest "GET /setup with no users" => sub {
    my $tx;

    $schema->resultset("User")->delete_all;

    $mech->get_ok(
        "/setup",
        "is ok"
    );

    $tx = prepare_html_tests;

    $tx->ok(
        '//input[@id="username"]',
        sub {
            is(
                $tx->node->getAttribute("required"),
                "",
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "username",
                "has correct name"
            );

            is(
                $tx->node->getAttribute("maxlength"),
                30,
                "has correct maxlength"
            );
        },
        "contains input for username"
    );

    $tx->ok(
        '//input[@id="display_name"]',
        sub {
            is(
                $tx->node->getAttribute("required"),
                "",
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "display_name",
                "has correct name"
            );

            is(
                $tx->node->getAttribute("maxlength"),
                50,
                "has correct maxlength"
            );
        },
        "contains input for display name"
    );

    $tx->ok(
        '//input[@id="password"]',
        sub {
            is(
                $tx->node->getAttribute("required"),
                "",
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "password",
                "has correct name"
            );

            is(
                $tx->node->getAttribute("minlength"),
                10,
                "has correct minlength"
            );

            is(
                $tx->node->getAttribute("type"),
                "password",
                "has correct type"
            );
        },
        "contains input for password"
    );

    $tx->ok(
        '//input[@id="confirm_password"]',
        sub {
            is(
                $tx->node->getAttribute("required"),
                "",
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "confirm_password",
                "has correct name"
            );

            is(
                $tx->node->getAttribute("minlength"),
                10,
                "has correct minlength"
            );

            is(
                $tx->node->getAttribute("type"),
                "password",
                "has correct type"
            );
        },
        "contains input for password confirm"
    );

    reset_fixtures;
};

subtest "GET /setup with users" => sub {
    subtest "and without login" => sub {
        $mech->get("/setup");

        $mech->header_is(
            "Status",
            302,
            "redirects"
        );

        $mech->header_is(
            "Location",
            "http://localhost/login",
            "redirects to home"
        );
    };

    subtest "and login" => sub {
        login_mech;

        $mech->get("/setup");

        $mech->header_is(
            "Status",
            302,
            "redirects"
        );

        $mech->header_is(
            "Location",
            "http://localhost/",
            "redirects to home"
        );
    };
};

subtest "POST /setup" => sub {
    $mech->cookie_jar->clear;
    $schema->resultset("User")->delete_all;

    subtest "without username" => sub {
        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                display_name     => "Foobar",
                password         => "X" x 10,
                confirm_password => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a Bad Request"
        );

        $mech->content_contains(
            "Could not create profile!",
            "contains error message"
        );
    };

    subtest "without display name" => sub {
        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                username         => "X" x 10,
                password         => "X" x 10,
                confirm_password => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a Bad Request"
        );

        $mech->content_contains(
            "Could not create profile!",
            "contains error message"
        );
    };

    subtest "without password" => sub {
        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                username         => "X" x 10,
                display_name     => "Foobar",
                confirm_password => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a Bad Request"
        );

        $mech->content_contains(
            "Could not create profile!",
            "contains error message"
        );
    };

    subtest "without confirm password" => sub {
        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                username         => "X" x 10,
                display_name     => "Foobar",
                password         => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a Bad Request"
        );

        $mech->content_contains(
            "Could not create profile!",
            "contains error message"
        );
    };

    subtest "with non-matching passwords" => sub {
        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                username         => "X" x 10,
                display_name     => "Foobar",
                password         => "X" x 10,
                confirm_password => "Y" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a Bad Request"
        );

        $mech->content_contains(
            "Could not create profile!",
            "contains error message"
        );
    };

    subtest "with too short password" => sub {
        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                username         => "X" x 10,
                display_name     => "Foobar",
                password         => "X" x 9,
                confirm_password => "X" x 9
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a Bad Request"
        );

        $mech->content_contains(
            "Could not create profile!",
            "contains error message"
        );
    };

    subtest "with too long username" => sub {
        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                username         => "X" x 31,
                display_name     => "Foobar",
                password         => "X" x 10,
                confirm_password => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a Bad Request"
        );

        $mech->content_contains(
            "Could not create profile!",
            "contains error message"
        );
    };

    subtest "with too long display name" => sub {
        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                username         => "X" x 31,
                display_name     => "X" x 51,
                password         => "X" x 10,
                confirm_password => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a Bad Request"
        );

        $mech->content_contains(
            "Could not create profile!",
            "contains error message"
        );
    };

    subtest "with correct data" => sub {
        my $user;

        $mech->get("/setup");

        $mech->submit_form((
            form_id => "setup_form",
            fields => {
                username         => "X" x 30,
                display_name     => "X" x 50,
                password         => "X" x 10,
                confirm_password => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            302,
            "is a redirect"
        );

        $mech->header_is(
            "Location",
            "http://localhost/",
            "redirects to home"
        );

        is(
            $schema->resultset("User")->count,
            1,
            "has created a user"
        );

        $user = $schema->resultset("User")->find(1);

        is(
            $user->username,
            "X" x 30,
            "has set username correctly"
        );

        is(
            $user->display_name,
            "X" x 50,
            "has set display name correctly"
        );

        is(
            $user->password,
            sha512_base64("X" x 10),
            "has set password correctly"
        );
    };

    reset_fixtures;
};
