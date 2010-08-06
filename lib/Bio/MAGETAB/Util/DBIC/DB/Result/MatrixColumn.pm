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

package Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumn

=cut

__PACKAGE__->table("mt_matrix_column");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 data_matrix_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 column_number

  data_type: 'integer'
  is_nullable: 0

=head2 quantitation_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "data_matrix_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "column_number",
  { data_type => "integer", is_nullable => 0 },
  "quantitation_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 data_matrix

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DataMatrix>

=cut

__PACKAGE__->belongs_to(
  "data_matrix",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DataMatrix",
  { id => "data_matrix_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 quantitation_type

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->belongs_to(
  "quantitation_type",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { id => "quantitation_type_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 matrix_column_node_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumnNodeLink>

=cut

__PACKAGE__->has_many(
  "matrix_column_node_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixColumnNodeLink",
  { "foreign.matrix_column_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 nodes

Type: many_to_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->many_to_many(
    "nodes" => "matrix_column_node_links", "node"
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
