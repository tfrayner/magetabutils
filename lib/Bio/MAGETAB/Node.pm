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

no Moose;

1;
