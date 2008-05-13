# $Id$

package Bio::MAGETAB::Material;

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

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'type'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_type',
                               predicate  => 'has_type',
                               required   => 0 );

has 'characteristics'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               clearer    => 'clear_characteristics',
                               predicate  => 'has_characteristics',
                               required   => 0 );

has 'measurements'        => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Measurement]',
                               auto_deref => 1,
                               clearer    => 'clear_measurements',
                               predicate  => 'has_measurements',
                               required   => 0 );

no Moose;

1;
