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

=head2 sdrf_row_factor_value_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRowFactorValueLink>

=cut

__PACKAGE__->has_many(
  "sdrf_row_factor_value_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::SdrfRowFactorValueLink",
  { "foreign.factor_value_id" => "self.id" },
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
