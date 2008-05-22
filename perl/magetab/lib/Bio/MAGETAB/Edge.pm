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

package Bio::MAGETAB::Edge;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'inputNode'            => ( is         => 'rw',
                                isa        => 'Bio::MAGETAB::Node',
                                weak_ref   => 1,
                                required   => 1 );

has 'outputNode'           => ( is         => 'rw',
                                isa        => 'Bio::MAGETAB::Node',
                                weak_ref   => 1,
                                required   => 1 );

has 'protocolApplications' => ( is         => 'rw',
                                isa        => 'ArrayRef[Bio::MAGETAB::ProtocolApplication]',
                                auto_deref => 1,
                                clearer    => 'clear_protocolApplications',
                                predicate  => 'has_protocolApplications',
                                required   => 0 );

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old edges from the old node
# and remove this edge.
around 'set_inputNode' => sub {

    my ( $attr, $self, $node ) = @_;

    $self->_reciprocate_1toN_attribute_setting(
        $attr,
        $node,
        'inputNode',
        'outputEdges',
    );
};

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old edges from the old node
# and remove this edge.
around 'set_outputNode' => sub {

    my ( $attr, $self, $node ) = @_;

    $self->_reciprocate_1toN_attribute_setting(
        $attr,
        $node,
        'outputNode',
        'inputEdges',
    );
};

no Moose;

1;
