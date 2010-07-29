# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue;




use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::FactorValue

=cut

__PACKAGE__->table("mt_factor_value");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 measurement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 term_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 factor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "measurement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "term_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "factor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 measurement

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Measurement>

=cut

__PACKAGE__->belongs_to(
  "measurement",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Measurement",
  { id => "measurement_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 term

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "term",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "term_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 factor

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Factor>

=cut

__PACKAGE__->belongs_to(
  "factor",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Factor",
  { id => "factor_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
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
  { "foreign.factor_value_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);







1;
