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
        '//form[@id="profileForm"]//div[@class="button-row"]//a',
        sub {
            is(
                $tx->node->getAttribute("href"),
                "http://localhost/profile",
                "href attribute correct"
            );
        },
        "contains link back to profile"
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

    $tx->ok(
        '//section[@class="profile-mathjax"]',
        "contains section for mathjax"
    );

    $tx->ok(
        '//section[@class="profile-mathjax"]//div[@class="toggle"]/input',
        sub {
            ok(
                !$tx->node->hasAttribute("checked"),
                "toggle input is not checked"
            );
        },
        "contains unchecked mathjax toggle"
    );

    $tx->ok(
        '//section[@class="profile-max-rating"]',
        "contains section for max-rating"
    );

    $tx->ok(
        '//section[@class="profile-max-rating"]/input',
        sub {
            is(
                $tx->node->getAttribute("value"),
                "",
                "max rating input has correct value"
            );
        },
        "contains input for max-rating"
    );
};

subtest "GET /profile/edit with second user" => sub {
    login_mech "second_user";

    $mech->get("/profile/edit");

    $tx = prepare_html_tests;

    $tx->ok(
        '//section[@class="profile-mathjax"]//div[@class="toggle"]/input',
        sub {
            ok(
                $tx->node->hasAttribute("checked"),
                "toggle input is checked"
            );
        },
        "contains checked mathjax toggle"
    );

    $tx->ok(
        '//section[@class="profile-max-rating"]/input',
        sub {
            is(
                $tx->node->getAttribute("value"),
                "25",
                "max rating input has correct value"
            );
        },
        "contains input for max-rating"
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
                    display_name => "New",
                    max_rating   => 25
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

        is(
            $schema->resultset("User")->find(1)->mathjax_enabled,
            0,
            "updated mathjax_enabled correctly"
        );

        is(
            $schema->resultset("User")->find(1)->max_rating,
            25,
            "updated max_rating correctly"
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

        $tx->like(
            '//section[@class="profile-max-rating"]' .
                '/div[@class="profile-attribute-value"]',
            qr/25/,
            "contains correct new value for max_rating"
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

    subtest "update display_name without changing username" => sub {
        $mech->get("/profile/edit");

        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username     => "<b>admin</b>",
                    display_name => "new display_name"
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
            "<b>admin</b>",
            "username was left intact"
        );

        is(
            $schema->resultset("User")->find(1)->display_name,
            "new display_name",
            "display_name has been set correctly"
        );

        reset_fixtures;
    };

    subtest "enable MathJax" => sub {
        $mech->get("/profile/edit");

        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username        => "<b>admin</b>",
                    display_name    => "<b>Admin</b>",
                    mathjax_enabled => "on"
                },
            )
        );

        $mech->header_is(
            "Status",
            302,
            "has correct status"
        );

        is(
            $schema->resultset("User")->find(1)->mathjax_enabled,
            1,
            "mathjax_enabled has been set correctly"
        );

        reset_fixtures;
    };

    subtest "set max_rating to a string" => sub {
        $mech->get("/profile/edit");

        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username        => "<b>admin</b>",
                    display_name    => "<b>Admin</b>",
                    max_rating      => "foo123"
                },
            )
        );

        $mech->header_is(
            "Status",
            400,
            "has correct status"
        );

        reset_fixtures;
    };

    subtest "set max_rating to a float" => sub {
        $mech->get("/profile/edit");

        $mech->submit_form((
                form_id => "profileForm",
                fields  => {
                    username        => "<b>admin</b>",
                    display_name    => "<b>Admin</b>",
                    max_rating      => 13.37
                },
            )
        );

        $mech->header_is(
            "Status",
            400,
            "has correct status"
        );

        is(
            $schema->resultset("User")->find(1)->max_rating,
            0,
            "left max_rating intact"
        );

        reset_fixtures;
    };
};
