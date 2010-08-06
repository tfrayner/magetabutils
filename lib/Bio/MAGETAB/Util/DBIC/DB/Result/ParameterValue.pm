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

package Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::ParameterValue

=cut

__PACKAGE__->table("mt_parameter_value");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 protocol_application_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 measurement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 protocol_parameter_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "protocol_application_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "measurement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "protocol_parameter_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 protocol_application

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication>

=cut

__PACKAGE__->belongs_to(
  "protocol_application",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolApplication",
  { id => "protocol_application_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 protocol_parameter

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter>

=cut

__PACKAGE__->belongs_to(
  "protocol_parameter",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ProtocolParameter",
  { id => "protocol_parameter_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

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
