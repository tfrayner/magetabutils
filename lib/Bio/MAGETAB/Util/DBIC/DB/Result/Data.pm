# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Data;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Data

=cut

__PACKAGE__->table("mt_data");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 uri

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 data_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "uri",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "data_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 data_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "data_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "data_type_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Node",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 data_file

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DataFile>

=cut

__PACKAGE__->might_have(
  "data_file",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DataFile",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 data_matrix

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DataMatrix>

=cut

__PACKAGE__->might_have(
  "data_matrix",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DataMatrix",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
