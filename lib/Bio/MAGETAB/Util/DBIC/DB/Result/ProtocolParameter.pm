# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter

=cut

__PACKAGE__->table("mt_protocol_parameter");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 protocol_id

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
  "protocol_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 parameter_values

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue>

=cut

__PACKAGE__->has_many(
  "parameter_values",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue",
  { "foreign.protocol_parameter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 protocol

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Protocol>

=cut

__PACKAGE__->belongs_to(
  "protocol",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Protocol",
  { id => "protocol_id" },
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







1;
