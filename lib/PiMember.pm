package PiMember;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use CSS::Sass;


# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple

    Authentication

    Session
    Session::Store::File
    Session::State::Cookie

    StatusMessage
/;

extends 'Catalyst';

our $VERSION = '0.18';

# Configure the application.
#
# Note that settings in pimember.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'PiMember',
    version => $VERSION,
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    'Plugin::Authentication' => {
        default => {
            credential => {
                class => 'Password',
                password_type => 'hashed',
                password_hash_type => 'SHA-512',
            },
            store => {
                class => 'DBIx::Class',
                user_model => 'DB::User',
            }
        }
    },
);

unless ($ENV{TESTING}) {
    # compile SCSS to CSS
    my $sass = CSS::Sass->new(
        output_style => SASS_STYLE_COMPRESSED
    );

    my $css = $sass->compile_file("scss/styles.scss");

    open my $fh, ">", "root/static/styles.css";
    print $fh $css;
    close $fh;
}

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

PiMember - Catalyst based application

=head1 SYNOPSIS

    script/pimember_server.pl

=head1 DESCRIPTION

This is a simple application to handle file cards which can be used to learn
and memorize things.

=head1 SEE ALSO

L<PiMember::Controller::Root>, L<Catalyst>

=cut

1;
