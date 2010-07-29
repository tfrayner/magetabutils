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

=head2 edge_input_nodes

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Edge>

=cut

__PACKAGE__->has_many(
  "edge_input_nodes",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Edge",
  { "foreign.input_node_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 edge_output_nodes

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Edge>

=cut

__PACKAGE__->has_many(
  "edge_output_nodes",
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

=head2 sdrf_node_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfNodeLink>

=cut

__PACKAGE__->has_many(
  "sdrf_node_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfNodeLink",
  { "foreign.node_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
