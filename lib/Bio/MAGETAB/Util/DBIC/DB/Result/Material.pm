# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Material;




use strict;
use warnings;

use base 'DBIx::Class::Core';


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

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Node",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
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







1;
