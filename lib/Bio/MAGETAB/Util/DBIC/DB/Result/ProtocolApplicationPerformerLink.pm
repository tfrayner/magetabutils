# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplicationPerformerLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplicationPerformerLink

=cut

__PACKAGE__->table("mt_protocol_application_performer_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 protocol_application_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 performer_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "protocol_application_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "performer_id",
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

=head2 performer

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Contact>

=cut

__PACKAGE__->belongs_to(
  "performer",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Contact",
  { id => "performer_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
