# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Source;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Source

=cut

__PACKAGE__->table("mt_source");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Material",
  { id => "id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 source_provider_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SourceProviderLink>

=cut

__PACKAGE__->has_many(
  "source_provider_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SourceProviderLink",
  { "foreign.source_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
