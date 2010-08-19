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

package Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ +Bio::MAGETAB::Util::DBIC::DB::Row /);

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm

=cut

__PACKAGE__->table("mt_controlled_term");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 category

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 value

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "category",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 array_design_technology_types

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign>

=cut

__PACKAGE__->has_many(
  "array_design_technology_types",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign",
  { "foreign.technology_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 array_design_surface_types

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign>

=cut

__PACKAGE__->has_many(
  "array_design_surface_types",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign",
  { "foreign.surface_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 array_design_substrate_types

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign>

=cut

__PACKAGE__->has_many(
  "array_design_substrate_types",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign",
  { "foreign.substrate_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 array_design_sequence_polymer_types

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign>

=cut

__PACKAGE__->has_many(
  "array_design_sequence_polymer_types",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign",
  { "foreign.sequence_polymer_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 assays

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Assay>

=cut

__PACKAGE__->has_many(
  "assays",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Assay",
  { "foreign.technology_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 contact_role_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ContactRoleLink>

=cut

__PACKAGE__->has_many(
  "contact_role_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ContactRoleLink",
  { "foreign.role_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 datas

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Data>

=cut

__PACKAGE__->has_many(
  "datas",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Data",
  { "foreign.data_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 data_file

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DataFile>

=cut

__PACKAGE__->might_have(
  "data_file",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DataFile",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 factors

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Factor>

=cut

__PACKAGE__->has_many(
  "factors",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Factor",
  { "foreign.factor_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 factor_values

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue>

=cut

__PACKAGE__->has_many(
  "factor_values",
  "Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue",
  { "foreign.term_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_design_type_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationDesignTypeLink>

=cut

__PACKAGE__->has_many(
  "investigation_design_type_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationDesignTypeLink",
  { "foreign.design_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_normalization_type_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationNormalizationTypeLink>

=cut

__PACKAGE__->has_many(
  "investigation_normalization_type_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationNormalizationTypeLink",
  { "foreign.normalization_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_quality_control_type_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationQualityControlTypeLink>

=cut

__PACKAGE__->has_many(
  "investigation_quality_control_type_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationQualityControlTypeLink",
  { "foreign.quality_control_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_replicate_type_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationReplicateTypeLink>

=cut

__PACKAGE__->has_many(
  "investigation_replicate_type_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationReplicateTypeLink",
  { "foreign.replicate_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 labeled_extracts

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::LabeledExtract>

=cut

__PACKAGE__->has_many(
  "labeled_extracts",
  "Bio::MAGETAB::Util::DBIC::DB::Result::LabeledExtract",
  { "foreign.label_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 materials

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Material>

=cut

__PACKAGE__->has_many(
  "materials",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Material",
  { "foreign.material_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 material_characteristic_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MaterialCharacteristicLink>

=cut

__PACKAGE__->has_many(
  "material_characteristic_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MaterialCharacteristicLink",
  { "foreign.characteristic_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matrix_columns

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn>

=cut

__PACKAGE__->has_many(
  "matrix_columns",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn",
  { "foreign.quantitation_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 measurements

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Measurement>

=cut

__PACKAGE__->has_many(
  "measurements",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Measurement",
  { "foreign.unit_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 protocols

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Protocol>

=cut

__PACKAGE__->has_many(
  "protocols",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Protocol",
  { "foreign.protocol_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 publications

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Publication>

=cut

__PACKAGE__->has_many(
  "publications",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Publication",
  { "foreign.status_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reporters

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Reporter>

=cut

__PACKAGE__->has_many(
  "reporters",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Reporter",
  { "foreign.control_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reporter_group_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ReporterGroupLink>

=cut

__PACKAGE__->has_many(
  "reporter_group_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ReporterGroupLink",
  { "foreign.group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sdrf_rows

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow>

=cut

__PACKAGE__->has_many(
  "sdrf_rows",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow",
  { "foreign.channel_id" => "self.id" },
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
