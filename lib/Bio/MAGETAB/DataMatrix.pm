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

package Bio::MAGETAB::DataMatrix;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Data' };

has 'rowIdentifierType'   => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_rowIdentifierType',
                               predicate  => 'has_rowIdentifierType',
                               required   => 0 );

has 'matrixColumns'       => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::MatrixColumn]',
                               clearer    => 'clear_matrixColumns',
                               predicate  => 'has_matrixColumns',
                               auto_deref => 1,
                               required   => 0 );

has 'matrixRows'          => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::MatrixRow]',
                               clearer    => 'clear_matrixRows',
                               predicate  => 'has_matrixRows',
                               auto_deref => 1,
                               required   => 0 );

__PACKAGE__->meta->make_immutable();

no Moose;

1;
