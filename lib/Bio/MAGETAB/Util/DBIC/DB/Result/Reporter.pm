# Copyright 2008-2010 Tim Rayner
# 
# This file is part of Bio::MAGETAB.
# 
# Bio::MAGETAB is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Reporter;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Reporter

=cut

__PACKAGE__->table("mt_reporter");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 sequence

  accessor: undef
  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 control_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "sequence",
  { accessor => undef, data_type => "varchar", is_nullable => 1, size => 512 },
  "control_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 features

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Feature>

=cut

__PACKAGE__->has_many(
  "features",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Feature",
  { "foreign.reporter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 control_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "control_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "control_type_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 reporter_composite_element_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ReporterCompositeElementLink>

=cut

__PACKAGE__->has_many(
  "reporter_composite_element_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ReporterCompositeElementLink",
  { "foreign.reporter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 composite_elements

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement>

=cut

__PACKAGE__->many_to_many(
    "composite_elements" => "reporter_composite_element_links", "composite_element"
);

=head2 reporter_database_entry_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ReporterDatabaseEntryLink>

=cut

__PACKAGE__->has_many(
  "reporter_database_entry_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ReporterDatabaseEntryLink",
  { "foreign.reporter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 database_entries

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry>

=cut

__PACKAGE__->many_to_many(
    "database_entries" => "reporter_database_entry_links", "database_entry"
);

=head2 reporter_group_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ReporterGroupLink>

=cut

__PACKAGE__->has_many(
  "reporter_group_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ReporterGroupLink",
  { "foreign.reporter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 groups

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->many_to_many(
    "groups" => "reporter_group_links", "group"
);

=head2 design_element_id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement>

=cut

__PACKAGE__->belongs_to(
  "design_element_id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement",
  { id => "id" },
  { on_delete => "CASCADE",
    on_update => "CASCADE",
    proxy     => [qw( chromosome start_position end_position
                      namespace authority comments )], },
);

sub parent_class { 'DesignElement' }

__PACKAGE__->resultset_class('Bio::MAGETAB::Util::DBIC::DB::ResultSet');

1;

__END__

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
