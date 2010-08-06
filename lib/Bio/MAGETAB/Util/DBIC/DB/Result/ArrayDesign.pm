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

package Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign

=cut

__PACKAGE__->table("mt_array_design");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 version

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 uri

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 provider

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 technology_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 surface_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 substrate_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 printing_protocol

  data_type: 'text'
  is_nullable: 1

=head2 sequence_polymer_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "version",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "uri",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "provider",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "technology_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "surface_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "substrate_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "printing_protocol",
  { data_type => "text", is_nullable => 1 },
  "sequence_polymer_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 technology_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "technology_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "technology_type_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 surface_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "surface_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "surface_type_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 substrate_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "substrate_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "substrate_type_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 sequence_polymer_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "sequence_polymer_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "sequence_polymer_type_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 array_design_design_element_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesignDesignElementLink>

=cut

__PACKAGE__->has_many(
  "array_design_design_element_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesignDesignElementLink",
  { "foreign.array_design_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 design_elements

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement>

=cut

__PACKAGE__->many_to_many(
    "design_elements" => "array_design_design_element_links", "design_element"
);

=head2 assays

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Assay>

=cut

__PACKAGE__->has_many(
  "assays",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Assay",
  { "foreign.array_design_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 database_entry_id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry>

=cut

__PACKAGE__->belongs_to(
  "database_entry_id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry",
  { id => "id" },
  { on_delete => "CASCADE",
    on_update => "CASCADE",
    proxy     => [qw( term_source accession
                      namespace authority comments )], },
);

sub parent_class { 'DatabaseEntry' }

__PACKAGE__->resultset_class('Bio::MAGETAB::Util::DBIC::DB::ResultSet');

1;

__END__

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
