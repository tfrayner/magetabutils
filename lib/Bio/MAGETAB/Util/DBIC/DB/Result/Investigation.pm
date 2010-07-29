# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Investigation;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Investigation

=cut

__PACKAGE__->table("mt_investigation");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 date

  data_type: 'date'
  is_nullable: 1

=head2 public_release_date

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "date",
  { data_type => "date", is_nullable => 1 },
  "public_release_date",
  { data_type => "date", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 factors

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Factor>

=cut

__PACKAGE__->has_many(
  "factors",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Factor",
  { "foreign.investigation_id" => "self.id" },
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

=head2 investigation_contact_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationContactLink>

=cut

__PACKAGE__->has_many(
  "investigation_contact_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationContactLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_design_type_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationDesignTypeLink>

=cut

__PACKAGE__->has_many(
  "investigation_design_type_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationDesignTypeLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_normalization_type_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationNormalizationTypeLink>

=cut

__PACKAGE__->has_many(
  "investigation_normalization_type_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationNormalizationTypeLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_protocol_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationProtocolLink>

=cut

__PACKAGE__->has_many(
  "investigation_protocol_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationProtocolLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_publication_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationPublicationLink>

=cut

__PACKAGE__->has_many(
  "investigation_publication_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationPublicationLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_quality_control_type_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationQualityControlTypeLink>

=cut

__PACKAGE__->has_many(
  "investigation_quality_control_type_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationQualityControlTypeLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_replicate_type_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationReplicateTypeLink>

=cut

__PACKAGE__->has_many(
  "investigation_replicate_type_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationReplicateTypeLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_sdrf_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationSdrfLink>

=cut

__PACKAGE__->has_many(
  "investigation_sdrf_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationSdrfLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 investigation_term_source_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationTermSourceLink>

=cut

__PACKAGE__->has_many(
  "investigation_term_source_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationTermSourceLink",
  { "foreign.investigation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
