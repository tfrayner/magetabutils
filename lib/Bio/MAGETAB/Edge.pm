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

    $self->_reciprocate_attribute_setting(
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

    $self->_reciprocate_attribute_setting(
        $attr,
        $node,
        'outputNode',
        'inputEdges',
    );
};

no Moose;

1;
