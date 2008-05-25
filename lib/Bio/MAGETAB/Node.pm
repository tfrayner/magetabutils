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

package Bio::MAGETAB::Node;

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

has 'inputEdges'          => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Edge]',
                               auto_deref => 1,
                               required   => 0 );

has 'outputEdges'         => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Edge]',
                               auto_deref => 1,
                               required   => 0 );

has 'factorValues'        => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::FactorValue]',
                               auto_deref => 1,
                               required   => 0 );

has 'comment'             => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               required   => 0 );

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old nodes from the old edge
# and remove this node.
around 'set_inputEdges' => sub {

    my ( $attr, $self, $edges ) = @_;

    $self->_reciprocate_edges_to_nodes(
        $attr,
        $edges,
        'outputNode',
    );
};

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old nodes from the old edge
# and remove this node.
around 'set_outputEdges' => sub {

    my ( $attr, $self, $edges ) = @_;

    $self->_reciprocate_edges_to_nodes(
        $attr,
        $edges,
        'inputNode',
    );
};

# This method is used as a wrapper to ensure that reciprocating
# relationships are maintained, even when updating object attributes.
sub _reciprocate_edges_to_nodes {

    # $attr :       CODEREF for setting attribute
    #                 (see Moose docs, particularly with regard to "around").
    # $edges:       The edges with which $self has a reciprocal relationship.
    # $self_slot:     The name of the slot pointing from $self to $edge.
    # $edge_slot:   The name of the slot pointing from $edge to $self.
    my ( $self, $attr, $edges, $edge_slot ) = @_;

    # Set the appropriate $self attribute to point to $edges.
    $attr->( $self, $edges );

    # Make sure $edges points to us. Since Edge->Node is 1..* we can
    # just overwrite the node attribute in the edges without worrying
    # about what else it might have pointed to.
    foreach my $t ( @$edges ) {
        $t->{ $edge_slot } = $self;
    }

    return;
}

no Moose;

1;
