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

package Bio::MAGETAB::DesignElement;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

# This is an abstract class; block direct instantiation.
sub BUILD {

    my ( $self, $params ) = @_;

    if ( blessed $self eq __PACKAGE__ ) {
        confess("ERROR: Attempt to instantiate abstract class " . __PACKAGE__);
    }

    return;
}

__PACKAGE__->meta->make_immutable();

no Moose;

1;
