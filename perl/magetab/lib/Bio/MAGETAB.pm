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

package Bio::MAGETAB;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::BaseClass;

# Convenience class for module loading and object tracking.

our $VERSION = 0.1;

# This cache is used to store all the Bio::MAGETAB objects registered
# with this instance (which, by default, is all of them).
has 'object_cache'          => ( is         => 'rw',
                                 isa        => 'HashRef',
                                 default    => sub{ {} },
                                 required   => 0 );

# Non-recursive, so we can set up e.g. a Util subdirectory without
# breaking anything.
my $magetab_modules = [
    qw(
       Bio::MAGETAB::ArrayDesign
       Bio::MAGETAB::Assay
       Bio::MAGETAB::BaseClass
       Bio::MAGETAB::Comment
       Bio::MAGETAB::CompositeElement
       Bio::MAGETAB::Contact
       Bio::MAGETAB::ControlledTerm
       Bio::MAGETAB::Data
       Bio::MAGETAB::DataAcquisition
       Bio::MAGETAB::DataFile
       Bio::MAGETAB::DataMatrix
       Bio::MAGETAB::DatabaseEntry
       Bio::MAGETAB::DesignElement
       Bio::MAGETAB::Edge
       Bio::MAGETAB::Event
       Bio::MAGETAB::Extract
       Bio::MAGETAB::Factor
       Bio::MAGETAB::FactorValue
       Bio::MAGETAB::Feature
       Bio::MAGETAB::Investigation
       Bio::MAGETAB::LabeledExtract
       Bio::MAGETAB::Material
       Bio::MAGETAB::MatrixColumn
       Bio::MAGETAB::MatrixRow
       Bio::MAGETAB::Measurement
       Bio::MAGETAB::Node
       Bio::MAGETAB::Normalization
       Bio::MAGETAB::ParameterValue
       Bio::MAGETAB::Protocol
       Bio::MAGETAB::ProtocolApplication
       Bio::MAGETAB::ProtocolParameter
       Bio::MAGETAB::Publication
       Bio::MAGETAB::Reporter
       Bio::MAGETAB::SDRF
       Bio::MAGETAB::Sample
       Bio::MAGETAB::Source
       Bio::MAGETAB::TermSource
   ) ];

# Load each module and install an accessor to return all the objects
# of each given class. FIXME it would also be good if superclasses
# could return their subclass instances as well (e.g. get_nodes also
# returns Material objects).
my %irregular_plural = (
    'BaseClass'     => 'BaseClasses',
    'Data'          => 'Data',
    'DataMatrix'    => 'DataMatrices',
    'DatabaseEntry' => 'DatabaseEntries',
);

foreach my $module ( @{ $magetab_modules } ) {

    ## no critic ProhibitStringyEval
    eval "require $module";
    ## use critic ProhibitStringyEval

    if ( $@ ) {
        die("Error loading module $module: $@");
    }

    my $slot = $module;
    my $namespace = __PACKAGE__;
    $slot =~ s/^${namespace}:://;
    $slot = $irregular_plural{$slot} || "${slot}s";
    $slot = lcfirst($slot);

    {
        no strict qw(refs);

        *{"get_${slot}"} = sub {
            my ( $self ) = @_;
            return $self->get_objects( $module );
	};

        *{"has_${slot}"} = sub {
            my ( $self ) = @_;
            return scalar $self->get_objects( $module ) ? 1 : q{};
	};
    }
}

sub BUILD {

    my ( $self, $params ) = @_;

    foreach my $param ( keys %{ $params } ) {
        my $getter = "get_$param";
        unless ( $self->can( $getter ) ) {
            confess("ERROR: Unrecognised parameter: $param");
        }
    }

    # Set the BaseClass container to the latest instance of this
    # class. FIXME this may get confusing; might be better just to get
    # the user to set this themselves?
    Bio::MAGETAB::BaseClass->set_ClassContainer( $self );

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
            return values %{ $objhash };
        }
        else {
            return;
        }
    }

    else {

        my @objects;
        while ( my ( $class, $objhash ) = each %{ $self->get_object_cache() } ) {
            push @objects, values %{ $objhash };
        }

        return @objects;
    }
}

__PACKAGE__->meta->make_immutable();

no Moose;

1;
