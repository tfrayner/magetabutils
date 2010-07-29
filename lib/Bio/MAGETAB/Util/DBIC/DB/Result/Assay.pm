# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Assay;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Assay

=cut

__PACKAGE__->table("mt_assay");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 array_design_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 technology_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "array_design_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "technology_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 array_design

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign>

=cut

__PACKAGE__->belongs_to(
  "array_design",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign",
  { id => "array_design_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 technology_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "technology_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "technology_type_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Event",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
