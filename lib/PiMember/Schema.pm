use utf8;
package PiMember::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-09 12:25:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7psqZy4DPdNOSQxK23lIng


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;

=encoding utf8

=head1 NAME

PiMember::Schema

=head1 DESCRIPTION

Schema to be used by DBIx::Class

=head1 AUTHOR

Kai Mörker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
