# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement

=cut

__PACKAGE__->table("mt_composite_element");

=head1 ACCESSORS

=head2 id

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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 composite_element_database_entry_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElementDatabaseEntryLink>

=cut

__PACKAGE__->has_many(
  "composite_element_database_entry_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElementDatabaseEntryLink",
  { "foreign.composite_element_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reporter_composite_element_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ReporterCompositeElementLink>

=cut

__PACKAGE__->has_many(
  "reporter_composite_element_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ReporterCompositeElementLink",
  { "foreign.composite_element_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
