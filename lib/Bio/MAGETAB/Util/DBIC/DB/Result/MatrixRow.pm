# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow

=cut

__PACKAGE__->table("mt_matrix_row");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 data_matrix_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 row_number

  data_type: 'integer'
  is_nullable: 0

=head2 design_element_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "data_matrix_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "row_number",
  { data_type => "integer", is_nullable => 0 },
  "design_element_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 data_matrix

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DataMatrix>

=cut

__PACKAGE__->belongs_to(
  "data_matrix",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DataMatrix",
  { id => "data_matrix_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 design_element

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement>

=cut

__PACKAGE__->belongs_to(
  "design_element",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement",
  { id => "design_element_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Base>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Base",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
