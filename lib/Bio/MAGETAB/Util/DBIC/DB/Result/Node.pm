# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Node;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Node

=cut

__PACKAGE__->table("mt_node");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 data

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Data>

=cut

__PACKAGE__->might_have(
  "data",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Data",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 output_edges

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Edge>

=cut

__PACKAGE__->has_many(
  "output_edges",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Edge",
  { "foreign.input_node_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 input_edges

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Edge>

=cut

__PACKAGE__->has_many(
  "input_edges",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Edge",
  { "foreign.output_node_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Event>

=cut

__PACKAGE__->might_have(
  "event",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Event",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 material

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Material>

=cut

__PACKAGE__->might_have(
  "material",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Material",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matrix_column_node_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumnNodeLink>

=cut

__PACKAGE__->has_many(
  "matrix_column_node_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumnNodeLink",
  { "foreign.node_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matrix_columns

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn>

=cut

__PACKAGE__->many_to_many(
    "matrix_columns" => "matrix_column_node_links", "matrix_column"
);

=head2 sdrf_row_node_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRowNodeLink>

=cut

__PACKAGE__->has_many(
  "sdrf_row_node_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRowNodeLink",
  { "foreign.node_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sdrf_rows

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow>

=cut

__PACKAGE__->many_to_many(
    "sdrf_rows" => "sdrf_row_node_links", "sdrf_row"
);

=head2 base_id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Base>

=cut

__PACKAGE__->belongs_to(
  "base_id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Base",
  { id => "id" },
  { on_delete => "CASCADE",
    on_update => "CASCADE",
    proxy     => [qw(namespace authority comments)] },
);

sub parent_class { 'Base' }

__PACKAGE__->resultset_class('Bio::MAGETAB::Util::DBIC::DB::ResultSet');

1;
