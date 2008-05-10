# $Id$

package Bio::MAGETAB;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::BaseClass;

our $VERSION = 0.1;

has 'object_cache'          => ( is         => 'rw',
                                 isa        => 'HashRef',
                                 required   => 0 );

# Convenience class for module loading. May want to use a Module::List
# type approach to just load everything in the Bio::MAGETAB namespace.

sub BUILD {

    my ( $self, $params ) = @_;

    # Set the BaseClass container to the latest instance of this
    # class. FIXME this may get confusing; might be better just to get
    # the user to set this themselves?
    Bio::MAGETAB::BaseClass->set_container( $self );

    return;
}

sub add_object {

    my ( $self, $object ) = @_;

    my $obj_hash = $self->get_object_cache();
    $obj_hash->{ blessed $object }{ $object } = $object;
    $self->set_object_cache( $obj_hash );

    return;
}

sub get_objects {

    my ( $self, $class ) = @_;

    if ( $class ) {

        # FIXME consider better validation of $class here.
        if ( my $objhash = $self->get_object_cache()->{ $class } ) {
            return [ values %{ $objhash } ];
        }
        else {
            return [];
        }
    }

    else {

        my @objects;
        while ( my ( $class, $objhash ) = each %{ $self->get_object_cache() } ) {
            push @objects, values %{ $objhash };
        }

        return \@objects;
    }
}

__PACKAGE__->meta->make_immutable();

no Moose;

1;
