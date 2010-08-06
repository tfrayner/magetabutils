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

package Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::MAGETAB::Util::DBIC::DB::Result::DatabaseEntry

=cut

__PACKAGE__->table("mt_database_entry");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 accession

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 term_source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "accession",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "term_source_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 array_design

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign>

=cut

__PACKAGE__->might_have(
  "array_design",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ArrayDesign",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 composite_element_database_entry_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElementDatabaseEntryLink>

=cut

__PACKAGE__->has_many(
  "composite_element_database_entry_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::CompositeElementDatabaseEntryLink",
  { "foreign.database_entry_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 controlled_term

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm>

=cut

__PACKAGE__->might_have(
  "controlled_term",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ControlledTerm",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 term_source

Type: belongs_to

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::TermSource>

=cut

__PACKAGE__->belongs_to(
  "term_source",
  "Bio::MAGETAB::Util::DBIC::DB::Result::TermSource",
  { id => "term_source_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 protocol

Type: might_have

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::Protocol>

=cut

__PACKAGE__->might_have(
  "protocol",
  "Bio::MAGETAB::Util::DBIC::DB::Result::Protocol",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reporter_database_entry_links

Type: has_many

Related object: L<Bio::MAGETAB::Util::DBIC::DB::Result::ReporterDatabaseEntryLink>

=cut

__PACKAGE__->has_many(
  "reporter_database_entry_links",
  "Bio::MAGETAB::Util::DBIC::DB::Result::ReporterDatabaseEntryLink",
  { "foreign.database_entry_id" => "self.id" },
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
