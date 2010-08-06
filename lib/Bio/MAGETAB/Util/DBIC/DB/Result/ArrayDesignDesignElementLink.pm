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

package Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesignDesignElementLink;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesignDesignElementLink

=cut

__PACKAGE__->table("mt_array_design_design_element_link");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 array_design_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 design_element_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "array_design_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "design_element_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 array_design

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign>

=cut

__PACKAGE__->belongs_to(
  "array_design",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign",
  { id => "array_design_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 design_element

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement>

=cut

__PACKAGE__->belongs_to(
  "design_element",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DesignElement",
  { id => "design_element_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

1;

__END__

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
