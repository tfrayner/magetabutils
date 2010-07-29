# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::MaterialMeasurementLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::MaterialMeasurementLink

=cut

__PACKAGE__->table("mt_material_measurement_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 material_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 measurement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "material_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "measurement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 material

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "material",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Material",
  { id => "material_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 measurement

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Measurement>

=cut

__PACKAGE__->belongs_to(
  "measurement",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Measurement",
  { id => "measurement_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
