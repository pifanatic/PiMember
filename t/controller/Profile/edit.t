use strict;
use warnings;
use FindBin;
use Test::More "no_plan";

BEGIN {
    require "$FindBin::Bin/../../lib/inc.pl";
}

my $tx;

subtest "GET /profile/edit with no login" => sub {
    $mech->get("/profile/edit");

    $mech->header_is(
        "Status",
        302,
        "redirects when accessing /profile/edit without login"
    );

    $mech->header_is(
        "Location",
        "http://localhost/login",
        "redirects to login when accessing /profile/edit without login"
    );
};

subtest "GET /profile/edit with login" => sub {
    login_mech;

    $mech->get_ok(
        "/profile/edit",
        "can GET /profile/edit when logged in"
    );

    $tx = prepare_html_tests;

    $tx->like(
        "//h1",
        qr/Edit Profile/,
        "sub-header contains correct heading"
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
        '//section[@class="profile-username"]',
        "contains section for username"
    );

    $tx->ok(
        '//section[@class="profile-username"]/input',
        sub {
            is(
                $tx->node->getAttribute("value"),
                "<b>admin</b>",
                "username input has correct value"
            );
        },
        "contains input for username"
    );

    $tx->ok(
        '//section[@class="profile-displayname"]',
        "contains section for displayname"
    );

    $tx->ok(
        '//section[@class="profile-displayname"]/input',
        sub {
            is(
                $tx->node->getAttribute("value"),
                "<b>Admin</b>",
                "displayname input has correct value"
            );
        },
        "contains input for displayname"
    );
};

subtest "POST /profile/edit" => sub {
    login_mech;

    subtest "no form-data at all" => sub {
        $mech->get("/profile/edit");

        $mech->submit_form((
            form_id => "profileForm",
            fields  => {
                username     => undef,
                display_name => undef
            },
        ));

        $mech->header_is(
            "Status",
            400,
            "has correct status"
        );

        $mech->content_contains("Profile update failed!");
    };

    subtest "missing display_name" => sub {
        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => "foo",
                    display_name => undef
                },
            )
        );
        $mech->header_is(
            "Status",
            400,
            "has correct status"
        );
        $mech->content_contains("Profile update failed!");
    };

    subtest "missing username" => sub {
        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => undef,
                    display_name => "FOO"
                },
            )
        );

        $mech->header_is(
            "Status",
            400,
            "has correct status"
        );

        $mech->content_contains("Profile update failed!");
    };

    subtest "username too long" => sub {
        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => "X" x 31,
                    display_name => "FOO"
                },
            )
        );

        $mech->header_is(
            "Status",
            400,
            "has correct status"
        );

        $mech->content_contains("Profile update failed!");
    };

    subtest "display_name too long" => sub {
        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => "foo",
                    display_name => "X" x 51
                },
            )
        );

        $mech->header_is(
            "Status",
            400,
            "has correct status"
        );

        $mech->content_contains("Profile update failed!");
    };

    subtest "username already exists" => sub {
        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => "second_user",
                    display_name => "Second User"
                },
            )
        );

        $mech->header_is(
            "Status",
            400,
            "has correct status"
        );

        $mech->content_contains(
            'Username &quot;second_user&quot; is already taken!'
        );
    };

    subtest "correct form-data" => sub {
        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => "new",
                    display_name => "New"
                },
            )
        );

        $mech->header_is(
            "Status",
            302,
            "redirects"
        );

        $mech->header_like(
            "Location",
            qr|^http://localhost/profile\?mid=\d{8}$|,
            "redirects to correct location"
        );

        $mech->get($mech->res->header("Location"));
        $mech->content_contains(
            "Profile updated!",
            "shows success hint"
        );

        is(
            $schema->resultset("User")->find(1)->username,
            "new",
            "updated username correctly"
        );

        is(
            $schema->resultset("User")->find(1)->display_name,
            "New",
            "updated display_name correctly"
        );

        $tx = prepare_html_tests;

        $tx->like(
            '//section[@class="profile-username"]' .
                '/div[@class="profile-attribute-value"]',
            qr/new/,
            "contains correct new value for username"
        );

        $tx->like(
            '//section[@class="profile-displayname"]' .
                '/div[@class="profile-attribute-value"]',
            qr|New|,
            "contains correct new value for displayname"
        );

        reset_fixtures;
    };

    subtest "maximum length username" => sub {
        $mech->get("/profile/edit");

        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => "X" x 30,
                    display_name => "Foo"
                },
            )
        );

        $mech->header_is(
            "Status",
            302,
            "has correct status"
        );

        is(
            $schema->resultset("User")->find(1)->username,
            "X" x 30,
            "username has been set correctly"
        );

        reset_fixtures;
    };

    subtest "maximum length display_name" => sub {
        $mech->get("/profile/edit");

        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => "foo",
                    display_name => "X" x 50
                },
            )
        );

        $mech->header_is(
            "Status",
            302,
            "has correct status"
        );

        is(
            $schema->resultset("User")->find(1)->display_name,
            "X" x 50,
            "display_name has been set correctly"
        );

        reset_fixtures;
    };
};
