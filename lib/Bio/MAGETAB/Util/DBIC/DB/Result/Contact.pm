# Copyright 2008-2010 Tim Rayner
# 
# This file is part of Bio::MAGETAB.
# 
# Bio::MAGETAB is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Contact;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ +Bio::MAGETAB::Util::DBIC::DB::Row /);

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

=head2 roles

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->many_to_many(
    "roles" => "contact_role_links", "role"
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

=head2 base_id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Base>

=cut

__PACKAGE__->belongs_to(
  "base_id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Base",
  { id => "id" },
  { on_delete => "CASCADE",
    on_update => "CASCADE",
    proxy     => [qw( namespace authority comments )], },
);

sub parent_class { 'Base' }

__PACKAGE__->resultset_class('Bio::MAGETAB::Util::DBIC::DB::ResultSet');

1;

__END__

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
