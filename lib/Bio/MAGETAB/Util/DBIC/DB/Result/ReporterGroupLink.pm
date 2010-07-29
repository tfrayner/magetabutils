# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::ReporterGroupLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ReporterGroupLink

=cut

__PACKAGE__->table("mt_reporter_group_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 reporter_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "reporter_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 reporter

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Reporter>

=cut

__PACKAGE__->belongs_to(
  "reporter",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Reporter",
  { id => "reporter_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 group

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "group",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "group_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
