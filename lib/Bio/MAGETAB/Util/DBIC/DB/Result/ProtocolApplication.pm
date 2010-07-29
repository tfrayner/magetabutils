# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication

=cut

__PACKAGE__->table("mt_protocol_application");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 edge_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 protocol_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 date

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "edge_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "protocol_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "date",
  { data_type => "date", is_nullable => 1 },
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
  { "foreign.protocol_application_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 edge

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Edge>

=cut

__PACKAGE__->belongs_to(
  "edge",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Edge",
  { id => "edge_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
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

=head2 protocol_application_performer_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplicationPerformerLink>

=cut

__PACKAGE__->has_many(
  "protocol_application_performer_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplicationPerformerLink",
  { "foreign.protocol_application_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
