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

package Bio::MAGETAB::ProtocolApplication;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::Types qw(Date);

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'protocol'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Protocol',
                               required   => 1 );

has 'parameterValues'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ParameterValue]',
                               auto_deref => 1,
                               clearer    => 'clear_parameterValues',
                               predicate  => 'has_parameterValues',
                               required   => 0 );

has 'performers'          => ( is         => 'rw',
                               isa        => 'ArrayRef[Str]',
                               auto_deref => 1,
                               clearer    => 'clear_performers',
                               predicate  => 'has_performers',
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               clearer    => 'clear_comments',
                               predicate  => 'has_comments',
                               required   => 0 );

has 'date'                => ( is         => 'rw',
                               isa        => 'Date',
                               clearer    => 'clear_date',
                               predicate  => 'has_date',
                               coerce     => 1,
                               required   => 0 );

no Moose;

1;
