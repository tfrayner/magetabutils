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

package Bio::MAGETAB::SDRF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::Types qw(Uri);

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'nodes'               => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Node]',
                               auto_deref => 1,
                               required   => 1 );

has 'uri'                 => ( is         => 'rw',
                               isa        => 'Uri',
                               coerce     => 1,
                               required   => 1 );

__PACKAGE__->meta->make_immutable();

no Moose;

1;
