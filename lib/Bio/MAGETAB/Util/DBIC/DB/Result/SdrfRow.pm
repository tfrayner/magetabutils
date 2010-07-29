# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRow

=cut

__PACKAGE__->table("mt_sdrf_row");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 sdrf_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 row_number

  data_type: 'integer'
  is_nullable: 1

=head2 channel_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "sdrf_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "row_number",
  { data_type => "integer", is_nullable => 1 },
  "channel_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

=head2 channel

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "channel",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "channel_id" },
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
