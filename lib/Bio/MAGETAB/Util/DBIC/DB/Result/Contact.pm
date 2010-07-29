# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Contact;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Contact

=cut

__PACKAGE__->table("mt_contact");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 mid_initials

  data_type: 'varchar'
  is_nullable: 1
  size: 11

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 organization

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 fax

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 address

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "mid_initials",
  { data_type => "varchar", is_nullable => 1, size => 11 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "organization",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "fax",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "address",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

=head2 contact_role_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ContactRoleLink>

=cut

__PACKAGE__->has_many(
  "contact_role_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ContactRoleLink",
  { "foreign.contact_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_contact_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationContactLink>

=cut

__PACKAGE__->has_many(
  "investigation_contact_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationContactLink",
  { "foreign.contact_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 protocol_application_performer_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplicationPerformerLink>

=cut

__PACKAGE__->has_many(
  "protocol_application_performer_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplicationPerformerLink",
  { "foreign.performer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 source_provider_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SourceProviderLink>

=cut

__PACKAGE__->has_many(
  "source_provider_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SourceProviderLink",
  { "foreign.provider_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
