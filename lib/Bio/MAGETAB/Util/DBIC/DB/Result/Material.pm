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

package Bio::MAGETAB::Util::DBIC::DB::Result::Material;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ +Bio::MAGETAB::Util::DBIC::DB::Row /);

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Material

=cut

__PACKAGE__->table("mt_material");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 material_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "material_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 extract

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Extract>

=cut

__PACKAGE__->might_have(
  "extract",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Extract",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 labeled_extract

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::LabeledExtract>

=cut

__PACKAGE__->might_have(
  "labeled_extract",
  "Bio::MAGETAB::Util::DBIC::DB::Result::LabeledExtract",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 material_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "material_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "material_type_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 material_characteristic_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MaterialCharacteristicLink>

=cut

__PACKAGE__->has_many(
  "material_characteristic_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MaterialCharacteristicLink",
  { "foreign.material_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 characteristics

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->many_to_many(
    "characteristics" => "material_characteristic_links", "characteristic"
);

=head2 material_measurement_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MaterialMeasurementLink>

=cut

__PACKAGE__->has_many(
  "material_measurement_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MaterialMeasurementLink",
  { "foreign.material_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 measurements

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Measurement>

=cut

__PACKAGE__->many_to_many(
    "measurements" => "material_measurement_links", "measurement"
);

=head2 sample

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Sample>

=cut

__PACKAGE__->might_have(
  "sample",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Sample",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 source

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Source>

=cut

__PACKAGE__->might_have(
  "source",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Source",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 node_id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "node_id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Node",
  { id => "id" },
  { on_delete => "CASCADE",
    on_update => "CASCADE",
    proxy     => [qw(input_edges output_edges sdrf_rows matrix_columns
                     namespace authority comments)] },
);

sub parent_class { 'Node' }

__PACKAGE__->resultset_class('Bio::MAGETAB::Util::DBIC::DB::ResultSet');

1;

__END__

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
