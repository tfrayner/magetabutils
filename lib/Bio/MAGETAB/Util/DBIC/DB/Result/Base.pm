# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Base;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Base

=cut

__PACKAGE__->table("mt_base");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 namespace

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 authority

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "namespace",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "authority",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 comments

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Comment>

N.B. This relationship describes those comments attached to an object
inheriting from the Base superclass.

=cut

__PACKAGE__->has_many(
  "comments",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Comment",
  { "foreign.base_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comment

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Comment>

N.B. This relationship is that of Comment inheriting from its Base
superclass.

=cut

__PACKAGE__->might_have(
  "comment",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Comment",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 contact

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Contact>

=cut

__PACKAGE__->might_have(
  "contact",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Contact",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 database_entry

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry>

=cut

__PACKAGE__->might_have(
  "database_entry",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 design_element

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement>

=cut

__PACKAGE__->might_have(
  "design_element",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 edge

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Edge>

=cut

__PACKAGE__->might_have(
  "edge",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Edge",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 factor

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Factor>

=cut

__PACKAGE__->might_have(
  "factor",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Factor",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 factor_value

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue>

=cut

__PACKAGE__->might_have(
  "factor_value",
  "Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Investigation>

=cut

__PACKAGE__->might_have(
  "investigation",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Investigation",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matrix_column

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn>

=cut

__PACKAGE__->might_have(
  "matrix_column",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matrix_row

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow>

=cut

__PACKAGE__->might_have(
  "matrix_row",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 measurement

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Measurement>

=cut

__PACKAGE__->might_have(
  "measurement",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Measurement",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 node

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->might_have(
  "node",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Node",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parameter_value

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue>

=cut

__PACKAGE__->might_have(
  "parameter_value",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 protocol_application

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication>

=cut

__PACKAGE__->might_have(
  "protocol_application",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 protocol_parameter

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter>

=cut

__PACKAGE__->might_have(
  "protocol_parameter",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 publication

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Publication>

=cut

__PACKAGE__->might_have(
  "publication",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Publication",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sdrf

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Sdrf>

=cut

__PACKAGE__->might_have(
  "sdrf",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Sdrf",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sdrf_row

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow>

=cut

__PACKAGE__->might_have(
  "sdrf_row",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 term_source

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::TermSource>

=cut

__PACKAGE__->might_have(
  "term_source",
  "Bio::MAGETAB::Util::DBIC::DB::Result::TermSource",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
