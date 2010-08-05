# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRowNodeLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRowNodeLink

=cut

__PACKAGE__->table("mt_sdrf_row_node_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sdrf_row_id

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
  "sdrf_row_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "node_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 sdrf_row

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow>

=cut

__PACKAGE__->belongs_to(
  "sdrf_row",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow",
  { id => "sdrf_row_id" },
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
