# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::DataMatrix;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::DataMatrix

=cut

__PACKAGE__->table("mt_data_matrix");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 row_identifier_type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "row_identifier_type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Data>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Data",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 matrix_columns

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn>

=cut

__PACKAGE__->has_many(
  "matrix_columns",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn",
  { "foreign.data_matrix_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matrix_rows

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow>

=cut

__PACKAGE__->has_many(
  "matrix_rows",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow",
  { "foreign.data_matrix_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
