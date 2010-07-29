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

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
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







1;
