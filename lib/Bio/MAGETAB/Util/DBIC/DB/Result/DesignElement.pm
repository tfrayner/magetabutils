# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement

=cut

__PACKAGE__->table("mt_design_element");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 chromosome

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 start_position

  data_type: 'integer'
  is_nullable: 1

=head2 end_position

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "chromosome",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "start_position",
  { data_type => "integer", is_nullable => 1 },
  "end_position",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 array_design_design_element_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesignDesignElementLink>

=cut

__PACKAGE__->has_many(
  "array_design_design_element_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesignDesignElementLink",
  { "foreign.design_element_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 composite_element

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement>

=cut

__PACKAGE__->might_have(
  "composite_element",
  "Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement",
  { "foreign.id" => "self.id" },
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

=head2 feature

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Feature>

=cut

__PACKAGE__->might_have(
  "feature",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Feature",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matrix_rows

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow>

=cut

__PACKAGE__->has_many(
  "matrix_rows",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow",
  { "foreign.design_element_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reporter

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Reporter>

=cut

__PACKAGE__->might_have(
  "reporter",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Reporter",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
