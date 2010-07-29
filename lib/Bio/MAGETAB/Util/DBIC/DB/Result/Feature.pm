# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Feature;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Feature

=cut

__PACKAGE__->table("mt_feature");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 block_col

  data_type: 'integer'
  is_nullable: 0

=head2 block_row

  data_type: 'integer'
  is_nullable: 0

=head2 col

  data_type: 'integer'
  is_nullable: 0

=head2 row

  data_type: 'integer'
  is_nullable: 0

=head2 reporter_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "block_col",
  { data_type => "integer", is_nullable => 0 },
  "block_row",
  { data_type => "integer", is_nullable => 0 },
  "col",
  { data_type => "integer", is_nullable => 0 },
  "row",
  { data_type => "integer", is_nullable => 0 },
  "reporter_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 reporter

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Reporter>

=cut

__PACKAGE__->belongs_to(
  "reporter",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Reporter",
  { id => "reporter_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
