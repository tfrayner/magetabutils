# $Id$

package Bio::MAGETAB::Feature;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::DesignElement' };

has 'blockColumn'         => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'blockRow'            => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'column'              => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'row'                 => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'reporter'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Reporter',
                               weak_ref   => 1,
                               required   => 1 );

# We use an "around" method to wrap this, rather than a trigger, so
# that we can search through the old features from the old reporter
# and remove this feature.
around 'set_reporter' => sub {

    my ( $attr, $self, $reporter ) = @_;

    $self->_reciprocate_attribute_setting(
        $attr,
        $reporter,
        'reporter',
        'features',
    );
};

no Moose;

1;
