# $Id$

package Bio::MAGETAB::Util::DBIC::DB::Result::Sample;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Sample

=cut

__PACKAGE__->table("mt_sample");

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

=head2 material_id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "material_id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Material",
  { id => "id" },
  { on_delete => "CASCADE",
    on_update => "CASCADE",
    proxy     => [qw(name description material_type characteristics measurements
                     input_edges output_edges sdrf_rows matrix_columns
                     namespace authority comments)], },
);

sub parent_class { 'Material' }

__PACKAGE__->resultset_class('Bio::MAGETAB::Util::DBIC::DB::ResultSet');

1;
