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

=head2 contacts

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Contact>

=cut

__PACKAGE__->many_to_many(
    "contacts" => "investigation_contact_links", "contact"
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

=head2 design_types

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->many_to_many(
    "design_types" => "investigation_design_type_links", "design_type"
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

=head2 normalization_types

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->many_to_many(
    "normalization_types" => "investigation_normalization_type_links", "normalization_type"
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

=head2 protocols

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Protocol>

=cut

__PACKAGE__->many_to_many(
    "protocols" => "investigation_protocol_links", "protocol"
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

=head2 publications

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Publication>

=cut

__PACKAGE__->many_to_many(
    "publications" => "investigation_publication_links", "publication"
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

=head2 quality_control_types

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->many_to_many(
    "quality_control_types" => "investigation_quality_control_type_links", "quality_control_type"
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

=head2 replicate_types

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->many_to_many(
    "replicate_types" => "investigation_replicate_type_links", "replicate_type"
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

=head2 sdrfs

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Sdrf>

=cut

__PACKAGE__->many_to_many(
    "sdrfs" => "investigation_sdrf_links", "sdrf"
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

=head2 term_sources

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::TermSource>

=cut

__PACKAGE__->many_to_many(
    "term_sources" => "investigation_term_source_links", "term_source"
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
