# $Id$

package Bio::MAGETAB::Event;

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

has 'name'                => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

no Moose;

1;
