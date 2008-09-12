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

# Convenience class for module loading and object tracking.
package Bio::MAGETAB;

use 5.008001;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::BaseClass;

use List::Util qw(first);

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
       Bio::MAGETAB::SDRFRow
       Bio::MAGETAB::Sample
       Bio::MAGETAB::Source
       Bio::MAGETAB::TermSource
   ) ];

my %irregular_plural = (
    'BaseClass'     => 'BaseClasses',
    'Data'          => 'Data',
    'DataMatrix'    => 'DataMatrices',
    'DatabaseEntry' => 'DatabaseEntries',
);

# Load each module and install an accessor to return all the objects
# of each given class (and their subclasses).
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
        unless ( UNIVERSAL::can( $self, $getter ) ) {
            confess("ERROR: Unrecognised parameter: $param");
        }
    }

    # Set the BaseClass container to the latest instance of this
    # class. FIXME this may get confusing; might be better just to get
    # the user to set this themselves?
    Bio::MAGETAB::BaseClass->set_ClassContainer( $self );

    return;
}

sub add_objects {

    my ( $self, @objects ) = @_;

    my $obj_hash = $self->get_object_cache();

    foreach my $object ( @objects ) {

        my $class = blessed $object;
        unless ( first { $_ eq $class } @{ $magetab_modules } ) {
            confess( qq{Error: Not a Bio::MAGETAB class: "$class"} );
        }

        $obj_hash->{ $class }{ $object } = $object;
    }

    $self->set_object_cache( $obj_hash );

    return;
}

sub delete_objects {

    my ( $self, @objects ) = @_;

    my $obj_hash = $self->get_object_cache();

    foreach my $object ( @objects ) {

        my $class = blessed $object;
        unless ( first { $_ eq $class } @{ $magetab_modules } ) {
            confess( qq{Error: Not a Bio::MAGETAB class: "$class"} );
        }

        delete $obj_hash->{ $class }{ $object }
    }

    $self->set_object_cache( $obj_hash );

    return;
}

sub get_objects {

    my ( $self, $class ) = @_;

    if ( $class ) {

        # We validate $class here.
        unless ( first { $_ eq $class } @{ $magetab_modules } ) {
            confess( qq{Error: Not a Bio::MAGETAB class: "$class"} );
        }

        # Recurse through all possible subclasses
        # (e.g. so that get_nodes() will return Material objects).
        my @members;
        foreach my $subclass ( $class, $class->meta->subclasses() ) {
            if ( my $objhash = $self->get_object_cache()->{ $subclass } ) {
                push @members, values %{ $objhash };
            }
        }

        return @members;
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

=head1 NAME

Bio::MAGETAB - A data model and supporting classes for the MAGE-TAB format.

=head1 SYNOPSIS

 use Bio::MAGETAB;
 my $sample = Bio::MAGETAB::Sample->new(name => 'Sample 1');

=head1 DESCRIPTION

This is the core set of classes used to support the Bio::MAGETAB
API. On its own this module is not terribly exciting, because all it
does is provide a set of data structures and type constraints which
help to reliably handle data in MAGE-TAB format. See the
L<Bio::MAGETAB::Util> module for classes which can be used to read,
write and visualize MAGE-TAB data.

=head1 SEE ALSO

L<Bio::MAGETAB::Util>, L<Bio::MAGETAB::Util::Reader>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
