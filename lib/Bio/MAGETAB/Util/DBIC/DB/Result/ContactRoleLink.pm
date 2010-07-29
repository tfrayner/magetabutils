# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::ContactRoleLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ContactRoleLink

=cut

__PACKAGE__->table("mt_contact_role_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 contact_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "contact_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contact

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Contact>

=cut

__PACKAGE__->belongs_to(
  "contact",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Contact",
  { id => "contact_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 role

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "role_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
