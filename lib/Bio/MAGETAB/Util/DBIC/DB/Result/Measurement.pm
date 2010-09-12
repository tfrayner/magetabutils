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

package Bio::MAGETAB::Util::DBIC::DB::Result::Measurement;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ +Bio::MAGETAB::Util::DBIC::DB::Row /);

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Measurement

=cut

__PACKAGE__->table("mt_measurement");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 measurement_type

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 min_value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 max_value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 unit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "measurement_type",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "min_value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "max_value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "unit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 factor_values

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue>

=cut

__PACKAGE__->has_many(
  "factor_values",
  "Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue",
  { "foreign.measurement_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 material_measurement_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MaterialMeasurementLink>

=cut

__PACKAGE__->has_many(
  "material_measurement_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MaterialMeasurementLink",
  { "foreign.measurement_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 materials

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Material>

=cut

__PACKAGE__->many_to_many(
    "materials" => "material_measurement_links", "material"
);

=head2 unit

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "unit",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "unit_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 parameter_values

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue>

=cut

__PACKAGE__->has_many(
  "parameter_values",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue",
  { "foreign.measurement_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 base_id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Base>

=cut

__PACKAGE__->belongs_to(
  "base_id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Base",
  { id => "id" },
  { on_delete => "CASCADE",
    on_update => "CASCADE",
    proxy     => [qw( namespace authority comments )], },
);

sub parent_class { 'Base' }

__PACKAGE__->resultset_class('Bio::MAGETAB::Util::DBIC::DB::ResultSet');

1;

__END__

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
