# $Id$

package Bio::MAGETAB::ProtocolParameter;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'protocol'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Protocol',
                               weak_ref   => 1,
                               required   => 1 );

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old parameters from the old protocol
# and remove this parameter.
around 'set_protocol' => sub {

    my ( $attr, $self, $protocol ) = @_;

    $self->_reciprocate_attribute_setting(
        $attr,
        $protocol,
        'protocol',
        'parameters',
    );
};

no Moose;

1;
