# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Protocol;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Protocol

=cut

__PACKAGE__->table("mt_protocol");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 text

  data_type: 'text'
  is_nullable: 1

=head2 software

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 hardware

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 protocol_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 contact

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "text",
  { data_type => "text", is_nullable => 1 },
  "software",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "hardware",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "protocol_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "contact",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 investigation_protocol_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationProtocolLink>

=cut

__PACKAGE__->has_many(
  "investigation_protocol_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationProtocolLink",
  { "foreign.protocol_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 protocol_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "protocol_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "protocol_type_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry",
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
  { "foreign.protocol_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 protocol_parameters

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter>

=cut

__PACKAGE__->has_many(
  "protocol_parameters",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter",
  { "foreign.protocol_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
