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

package Bio::MAGETAB::Publication;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'title'               => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'authorList'          => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_authorList',
                               predicate  => 'has_authorList',
                               required   => 0 );

has 'pubMedID'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_pubMedID',
                               predicate  => 'has_pubMedID',
                               required   => 0 );

has 'DOI'                 => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_DOI',
                               predicate  => 'has_DOI',
                               required   => 0 );

has 'status'              => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_status',
                               predicate  => 'has_status',
                               required   => 0 );

__PACKAGE__->meta->make_immutable();

no Moose;

1;
