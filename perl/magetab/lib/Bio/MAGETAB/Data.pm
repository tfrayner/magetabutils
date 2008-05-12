# $Id$

package Bio::MAGETAB::Data;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Node' };

# This is an abstract class; block direct instantiation.
sub BUILD {

    my ( $self, $params ) = @_;

    if ( blessed $self eq __PACKAGE__ ) {
        confess("ERROR: Attempt to instantiate abstract class " . __PACKAGE__);
    }

    return;
}

has 'uri'                 => ( is       => 'rw',
                               isa      => 'Str',    # FIXME needs URI data type.
                               required => 1 );

no Moose;

1;
