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

package Bio::MAGETAB::FactorValue;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'measurement'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Measurement',
                               clearer    => 'clear_measurement',
                               predicate  => 'has_measurement',
                               required   => 0 );

has 'term'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_term',
                               predicate  => 'has_term',
                               required   => 0 );

has 'channel'             => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_channel',
                               predicate  => 'has_channel',
                               required   => 0 );

has 'factor'              => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Factor',
                               required   => 1 );

__PACKAGE__->meta->make_immutable();

no Moose;

1;
