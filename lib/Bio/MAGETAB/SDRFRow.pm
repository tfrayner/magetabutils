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

package Bio::MAGETAB::SDRFRow;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Scalar::Util qw(weaken);
use List::Util qw(first);

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

sub BUILD {

    my ( $self, $params ) = @_;

    if ( defined $params->{'nodes'} ) {
        $self->set_nodes( $params->{'nodes'} );
        $self->_reciprocate_nodes_to_sdrf_rows(
            $params->{'nodes'},
            'sdrfRows',
        );
    }

    return;
}

has 'nodes'               => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Node]',
                               auto_deref => 1,
                               required   => 1 );

has 'rowNumber'           => ( is         => 'rw',
                               isa        => 'Int',
                               clearer    => 'clear_rowNumber',
                               predicate  => 'has_rowNumber',
                               required   => 0 );

has 'factorValues'        => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::FactorValue]',
                               auto_deref => 1,
                               clearer    => 'clear_factorValues',
                               predicate  => 'has_factorValues',
                               required   => 0 );

has 'channel'             => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_channel',
                               predicate  => 'has_channel',
                               required   => 0 );

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old edges from the old node
# and remove this edge.
around 'set_nodes' => sub {

    my ( $attr, $self, $nodes ) = @_;

    # Set the appropriate $self attribute to point to $node.
    $attr->( $self, $nodes );

    $self->_reciprocate_nodes_to_sdrf_rows(
        $nodes,
        'sdrfRows',
    );
};

# This method is used as a wrapper to ensure that reciprocating
# relationships are maintained, even when updating object attributes.
sub _reciprocate_nodes_to_sdrf_rows {

    # $node:        The node with which $self has a reciprocal relationship.
    # $node_slot:   The name of the slot pointing from $node to $self.
    my ( $self, $nodes, $node_slot ) = @_;

    my $node_getter = "get_$node_slot";

    # The Node-to-Row association is weakened to break a cicular
    # reference on object destruction.
    weaken $self;

    # Make sure $node points to us.
    foreach my $t ( $self->get_nodes() ) {
        my @current = $t->$node_getter();
        unless ( first { $_ eq $self } @current ) {
            push @current, $self;
            $t->{ $node_slot } = \@current;
        }
    }

    return;
}

__PACKAGE__->meta->make_immutable();

no Moose;

1;
