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

use List::Util qw(first);

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

    $self->_reciprocate_nodes_to_edges(
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

    $self->_reciprocate_nodes_to_edges(
        $attr,
        $node,
        'outputNode',
        'inputEdges',
    );
};

# This method is used as a wrapper to ensure that reciprocating
# relationships are maintained, even when updating object attributes.
sub _reciprocate_nodes_to_edges {

    # $attr :       CODEREF for setting attribute
    #                 (see Moose docs, particularly with regard to "around").
    # $node:        The node with which $self has a reciprocal relationship.
    #                 This can be either a scalar or an arrayref.
    # $self_slot:   The name of the slot pointing from $self to $node.
    # $node_slot:   The name of the slot pointing from $node to $self.
    my ( $self, $attr, $node, $self_slot, $node_slot ) = @_;

    my $self_getter = "get_$self_slot";
    my $node_getter = "get_$node_slot";

    # Remove $self from the list held by the old $node.
    my $old_node = $self->$self_getter();
    if ( $old_node ) {

        my @cleaned;
        foreach my $item ( $old_node->$node_getter() ) {
            push @cleaned, $item unless ( $item eq $self );
        }
        $old_node->{ $node_slot } = \@cleaned;
    }

    # Set the appropriate $self attribute to point to $node.
    $attr->( $self, $node );

    # Make sure $node points to us.
    my @current = $node->$node_getter();
    unless ( first { $_ eq $self } @current ) {
        push @current, $self;
        $node->{ $node_slot } = \@current;
    }

    return;
}

no Moose;

1;
