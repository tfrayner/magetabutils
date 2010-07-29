# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::SdrfFactorValueLink;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::SdrfFactorValueLink

=cut

__PACKAGE__->table("mt_sdrf_factor_value_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sdrf_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 factor_value_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sdrf_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "factor_value_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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

=head2 factor_value

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue>

=cut

__PACKAGE__->belongs_to(
  "factor_value",
  "Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue",
  { id => "factor_value_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
