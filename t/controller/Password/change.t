use strict;
use warnings;
use FindBin;
use Test::More "no_plan";
use Digest::SHA qw/ sha512_base64 /;

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

subtest "GET /password/change without login" => sub {
    $mech->get("/password/change");

    $mech->header_is(
        "Status",
        302,
        "redirects"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to /login"
    );
};

subtest "GET /password/change with login" => sub {
    my $tx;

    login_mech;

    $mech->get_ok(
        "/password/change",
        "is a success"
    );

    $tx = prepare_html_tests;

    $tx->like(
        '//div[@class="sub-header"]/h1',
        qr/Change password/,
        "contains correct heading"
    );

    $tx->ok(
        '//div[@class="sub-header-left"]/a',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/profile",
                "correct href attribute"
            )
        },
        "contains link back to profile page"
    );

    $tx->ok(
        '//input[@id="old_password"]',
        sub {
            is(
                $tx->node->getAttribute("type"),
                "password",
                "has correct type"
            );

            ok(
                $tx->node->hasAttribute("required"),
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "old_password",
                "has correct name"
            );
        },
        "contains input for old password"
    );

    $tx->ok(
        '//input[@id="new_password"]',
        sub {
            is(
                $tx->node->getAttribute("type"),
                "password",
                "has correct type"
            );

            ok(
                $tx->node->hasAttribute("required"),
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "new_password",
                "has correct name"
            );

            is(
                $tx->node->getAttribute("minlength"),
                "10",
                "has correct minlength"
            );
        },
        "contains input for new password"
    );

    $tx->ok(
        '//input[@id="new_password_repeat"]',
        sub {
            is(
                $tx->node->getAttribute("type"),
                "password",
                "has correct type"
            );

            ok(
                $tx->node->hasAttribute("required"),
                "is required"
            );

            is(
                $tx->node->getAttribute("name"),
                "new_password_repeat",
                "has correct name"
            );

            is(
                $tx->node->getAttribute("minlength"),
                "10",
                "has correct minlength"
            );
        },
        "contains input for new password repeat"
    );

    $tx->ok(
        '//div[@class="button-row"]//a[@class="btn btn-secondary"]',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/profile",
                "link has correct href"
            );
        },
        "contains button back to profile"
    );
};

subtest "POST /password/change" => sub {
    login_mech;

    subtest "without old_password" => sub {
        $mech->get("/password/change");

        $mech->submit_form((
            form_id => "passwordChange",
            fields => {
                new_password        => "X" x 10,
                new_password_repeat => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a bad request"
        );

        $mech->content_contains(
            "Password change failed!",
            "contains error message"
        );
    };

    subtest "without new_password" => sub {
        $mech->get("/password/change");

        $mech->submit_form((
            form_id => "passwordChange",
            fields => {
                old_password        => "X" x 10,
                new_password_repeat => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a bad request"
        );

        $mech->content_contains(
            "Password change failed!",
            "contains error message"
        );
    };

    subtest "without new_password_repeat" => sub {
        $mech->get("/password/change");

        $mech->submit_form((
            form_id => "passwordChange",
            fields => {
                old_password => "X" x 10,
                new_password => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a bad request"
        );

        $mech->content_contains(
            "Password change failed!",
            "contains error message"
        );
    };

    subtest "new_password too short" => sub {
        $mech->get("/password/change");

        $mech->submit_form((
            form_id => "passwordChange",
            fields => {
                old_password        => "X" x 10,
                new_password        => "X" x 9,
                new_password_repeat => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a bad request"
        );

        $mech->content_contains(
            "Password change failed!",
            "contains error message"
        );
    };

    subtest "new_password_repeat too short" => sub {
        $mech->get("/password/change");

        $mech->submit_form((
            form_id => "passwordChange",
            fields => {
                old_password        => "X" x 10,
                new_password        => "X" x 10,
                new_password_repeat => "X" x 9
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a bad request"
        );

        $mech->content_contains(
            "Password change failed!",
            "contains error message"
        );
    };

    subtest "new_passwords don't match" => sub {
        $mech->get("/password/change");

        $mech->submit_form((
            form_id => "passwordChange",
            fields => {
                old_password        => "X" x 10,
                new_password        => "X" x 10,
                new_password_repeat => "Y" x 10
            }
        ));

        $mech->header_is(
            "Status",
            400,
            "is a bad request"
        );

        $mech->content_contains(
            "Password change failed!",
            "contains error message"
        );
    };

    subtest "old_password not correct" => sub {
        $mech->get("/password/change");

        $mech->submit_form((
            form_id => "passwordChange",
            fields  => {
                old_password        => "NOT CORRECT",
                new_password        => "X" x 10,
                new_password_repeat => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            401,
            "is not authorized"
        );

        $mech->content_contains(
            "Current password incorrect!",
            "contains error message"
        );
    };

    subtest "correct form_data" => sub {
        $mech->get("/password/change");

        $mech->submit_form((
            form_id => "passwordChange",
            fields => {
                old_password        => "admin",
                new_password        => "X" x 10,
                new_password_repeat => "X" x 10
            }
        ));

        $mech->header_is(
            "Status",
            302,
            "redirects"
        );

        $mech->header_like(
            "Location",
            qr|http://localhost/profile\?mid=\d{8}|,
            "redirects to /profile"
        );

        $mech->get($mech->res->header("Location"));
        $mech->content_contains(
            "Password changed successfully",
            "displays success message"
        );

        is(
            $mech->c->model("DB::User")->find(1)->password,
            sha512_base64("X" x 10),
            "updated user correctly in db"
        );

        reset_fixtures;
    };
};
