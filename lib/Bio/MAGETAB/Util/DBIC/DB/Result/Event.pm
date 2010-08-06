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

package Bio::MAGETAB::Util::DBIC::DB::Result::Event;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::Event

=cut

__PACKAGE__->table("mt_event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 assay

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Assay>

=cut

__PACKAGE__->might_have(
  "assay",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Assay",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 data_acquisition

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::DataAcquisition>

=cut

__PACKAGE__->might_have(
  "data_acquisition",
  "Bio::MAGETAB::Util::DBIC::DB::Result::DataAcquisition",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 normalization

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Normalization>

=cut

__PACKAGE__->might_have(
  "normalization",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Normalization",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 node_id

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "node_id",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Node",
  { id => "id" },
  { on_delete => "CASCADE",
    on_update => "CASCADE",
    proxy     => [qw( input_edges output_edges sdrf_rows matrix_columns
                      namespace authority comments )], },
);

sub parent_class { 'Node' }

__PACKAGE__->resultset_class('Bio::MAGETAB::Util::DBIC::DB::ResultSet');

1;

__END__

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
