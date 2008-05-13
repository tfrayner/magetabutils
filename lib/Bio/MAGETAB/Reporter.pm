# Copyright 2008 Tim Rayner
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

package Bio::MAGETAB::Reporter;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::DesignElement' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'sequence'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_sequence',
                               predicate  => 'has_sequence',
                               required   => 0 );

has 'compositeElements'   => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::CompositeElement]',
                               auto_deref => 1,
                               clearer    => 'clear_compositeElements',
                               predicate  => 'has_compositeElements',
                               required   => 0 );

has 'databaseEntries'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::DatabaseEntry]',
                               auto_deref => 1,
                               clearer    => 'clear_databaseEntries',
                               predicate  => 'has_databaseEntries',
                               required   => 0 );

has 'controlType'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_controlType',
                               predicate  => 'has_controlType',
                               required   => 0 );

has 'groups'              => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               clearer    => 'clear_groups',
                               predicate  => 'has_groups',
                               required   => 0 );

no Moose;

1;
