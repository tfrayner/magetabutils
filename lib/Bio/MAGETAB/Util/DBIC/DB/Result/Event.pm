# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Event;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Event

=cut

__PACKAGE__->table("mt_event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 assay

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Assay>

=cut

__PACKAGE__->might_have(
  "assay",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Assay",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 data_acquisition

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DataAcquisition>

=cut

__PACKAGE__->might_have(
  "data_acquisition",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DataAcquisition",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 normalization

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Normalization>

=cut

__PACKAGE__->might_have(
  "normalization",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Normalization",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
