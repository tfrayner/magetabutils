# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Sdrf;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Sdrf

=cut

__PACKAGE__->table("mt_sdrf");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 uri

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "uri",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 investigation_sdrf_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationSdrfLink>

=cut

__PACKAGE__->has_many(
  "investigation_sdrf_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationSdrfLink",
  { "foreign.sdrf_id" => "self.id" },
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

=head2 sdrf_factor_value_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfFactorValueLink>

=cut

__PACKAGE__->has_many(
  "sdrf_factor_value_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfFactorValueLink",
  { "foreign.sdrf_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sdrf_node_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfNodeLink>

=cut

__PACKAGE__->has_many(
  "sdrf_node_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfNodeLink",
  { "foreign.sdrf_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sdrf_rows

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow>

=cut

__PACKAGE__->has_many(
  "sdrf_rows",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow",
  { "foreign.sdrf_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
