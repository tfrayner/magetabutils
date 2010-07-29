# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElementDatabaseEntryLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElementDatabaseEntryLink

=cut

__PACKAGE__->table("mt_composite_element_database_entry_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 composite_element_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 database_entry_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "composite_element_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "database_entry_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 composite_element

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement>

=cut

__PACKAGE__->belongs_to(
  "composite_element",
  "Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement",
  { id => "composite_element_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 database_entry

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry>

=cut

__PACKAGE__->belongs_to(
  "database_entry",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry",
  { id => "database_entry_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
