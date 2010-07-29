# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumnNodeLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumnNodeLink

=cut

__PACKAGE__->table("mt_matrix_column_node_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 matrix_column_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 node_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "matrix_column_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "node_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 matrix_column

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn>

=cut

__PACKAGE__->belongs_to(
  "matrix_column",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn",
  { id => "matrix_column_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 node

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "node",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Node",
  { id => "node_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
