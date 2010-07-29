# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Edge;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Edge

=cut

__PACKAGE__->table("mt_edge");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 input_node_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 output_node_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "input_node_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "output_node_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 input_node

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "input_node",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Node",
  { id => "input_node_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 output_node

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "output_node",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Node",
  { id => "output_node_id" },
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

=head2 protocol_applications

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication>

=cut

__PACKAGE__->has_many(
  "protocol_applications",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication",
  { "foreign.edge_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
