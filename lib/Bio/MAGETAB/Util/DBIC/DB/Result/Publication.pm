# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Publication;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Publication

=cut

__PACKAGE__->table("mt_publication");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 author_list

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 pub_med_id

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 doi

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 status_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "author_list",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "pub_med_id",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "doi",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "status_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 investigation_publication_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationPublicationLink>

=cut

__PACKAGE__->has_many(
  "investigation_publication_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationPublicationLink",
  { "foreign.publication_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 status

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "status",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "status_id" },
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
