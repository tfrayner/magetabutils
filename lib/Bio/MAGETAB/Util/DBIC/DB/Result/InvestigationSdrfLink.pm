# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationSdrfLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationSdrfLink

=cut

__PACKAGE__->table("mt_investigation_sdrf_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 investigation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 sdrf_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "investigation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "sdrf_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 investigation

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Investigation>

=cut

__PACKAGE__->belongs_to(
  "investigation",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Investigation",
  { id => "investigation_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 sdrf

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Sdrf>

=cut

__PACKAGE__->belongs_to(
  "sdrf",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Sdrf",
  { id => "sdrf_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
