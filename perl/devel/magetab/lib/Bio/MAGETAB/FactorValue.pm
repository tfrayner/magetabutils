# $Id$

package Bio::MAGETAB::FactorValue;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'measurement'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Measurement',
                               required   => 0 );

has 'term'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

has 'channel'             => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

has 'factor'              => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Factor',
                               weak_ref   => 1,
                               required   => 1 );

has 'nodes'               => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Node]',
                               auto_deref => 1,
                               required   => 1 );

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old fvs from the old factor
# and remove this fv.
around 'set_factor' => sub {

    my ( $attr, $self, $factor ) = @_;

    $self->_reciprocate_attribute_setting(
        $attr,
        $factor,
        'factor',
        'factorValues',
    );
};

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old fvs from the old nodes
# and remove this fv.
around 'set_factor' => sub {

    my ( $attr, $self, $nodes ) = @_;

    $self->_reciprocate_attribute_setting(
        $attr,
        $nodes,
        'nodes',
        'factorValues',
    );
};

no Moose;

1;
