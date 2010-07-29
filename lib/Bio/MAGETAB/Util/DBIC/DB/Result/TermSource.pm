# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::TermSource;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::TermSource

=cut

__PACKAGE__->table("mt_term_source");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 uri

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 version

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "uri",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "version",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 database_entries

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry>

=cut

__PACKAGE__->has_many(
  "database_entries",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry",
  { "foreign.term_source_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_term_source_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationTermSourceLink>

=cut

__PACKAGE__->has_many(
  "investigation_term_source_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationTermSourceLink",
  { "foreign.term_source_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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
