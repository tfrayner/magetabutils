# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn

=cut

__PACKAGE__->table("mt_matrix_column");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 data_matrix_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 column_number

  data_type: 'integer'
  is_nullable: 0

=head2 quantitation_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "data_matrix_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "column_number",
  { data_type => "integer", is_nullable => 0 },
  "quantitation_type_id",
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

=head2 quantitation_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "quantitation_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "quantitation_type_id" },
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

=head2 matrix_column_node_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumnNodeLink>

=cut

__PACKAGE__->has_many(
  "matrix_column_node_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumnNodeLink",
  { "foreign.matrix_column_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
