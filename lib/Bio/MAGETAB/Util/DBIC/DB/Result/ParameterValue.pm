# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue

=cut

__PACKAGE__->table("mt_parameter_value");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 protocol_application_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 measurement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 protocol_parameter_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "protocol_application_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "measurement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "protocol_parameter_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 protocol_application

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication>

=cut

__PACKAGE__->belongs_to(
  "protocol_application",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication",
  { id => "protocol_application_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 protocol_parameter

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter>

=cut

__PACKAGE__->belongs_to(
  "protocol_parameter",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter",
  { id => "protocol_parameter_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 measurement

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Measurement>

=cut

__PACKAGE__->belongs_to(
  "measurement",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Measurement",
  { id => "measurement_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
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
