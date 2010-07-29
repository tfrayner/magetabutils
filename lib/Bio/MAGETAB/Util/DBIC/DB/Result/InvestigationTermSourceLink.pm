# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationTermSourceLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::InvestigationTermSourceLink

=cut

__PACKAGE__->table("mt_investigation_term_source_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 investigation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 term_source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "investigation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "term_source_id",
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

=head2 term_source

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::TermSource>

=cut

__PACKAGE__->belongs_to(
  "term_source",
  "Bio::MAGETAB::Util::DBIC::DB::Result::TermSource",
  { id => "term_source_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
