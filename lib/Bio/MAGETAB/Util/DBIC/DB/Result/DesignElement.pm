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

package Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ +Bio::MAGETAB::Util::DBIC::DB::Row /);

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement

=cut

__PACKAGE__->table("mt_design_element");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 chromosome

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 start_position

  data_type: 'integer'
  is_nullable: 1

=head2 end_position

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "chromosome",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "start_position",
  { data_type => "integer", is_nullable => 1 },
  "end_position",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 array_design_design_element_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesignDesignElementLink>

=cut

__PACKAGE__->has_many(
  "array_design_design_element_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesignDesignElementLink",
  { "foreign.design_element_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 composite_element

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement>

=cut

__PACKAGE__->might_have(
  "composite_element",
  "Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElement",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 feature

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Feature>

=cut

__PACKAGE__->might_have(
  "feature",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Feature",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matrix_rows

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow>

=cut

__PACKAGE__->has_many(
  "matrix_rows",
  "Bio::MAGETAB::Util::DBIC::DB::Result::MatrixRow",
  { "foreign.design_element_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reporter

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Reporter>

=cut

__PACKAGE__->might_have(
  "reporter",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Reporter",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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
