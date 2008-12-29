# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB::Util.
# 
# Bio::MAGETAB::Util is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB::Util is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB::Util.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package Bio::MAGETAB::Util::DBLoader;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB;
use Carp;
use List::Util qw( first );
use English qw( -no_match_vars );

extends 'Bio::MAGETAB::Util::Builder';

has 'database'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Util::Persistence',
                               required   => 1,
                               handles    => [ qw( update ) ], );

sub _query_database {

    my ( $self, $class, $data, $id_fields ) = @_;

    # FIXME;
    my $remote = $self->get_database()->remote( $class );

    my $filter;
    foreach my $field ( @{ $id_fields } ) {

        # FIXME deal with aggregators somewhere, probably in a second select?

        # Much operator overloading mean that we have to be careful here.
        if ( $filter ) {
            $filter &= ( $remote->{ $field } eq $data->{ $field } );
        }
        else {
            $filter  = ( $remote->{ $field } eq $data->{ $field } );
        }
    }

    my @objects = $self->get_database()->select( $remote, $filter );

    if ( scalar @objects > 1 ) {
        confess("Error: multiple $class objects found in database.");
    }

    return $objects[0];
}

sub _get_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    if ( my $retval = $self->_query_database( $class, $data, $id_fields ) ) {
        return $retval;
    }
    elsif ( $self->get_relaxed_parser() ) {

        # If we're relaxing constraints, try and create an
        # empty object (in most cases this will probably fail
        # anyway).
        my $retval;
        eval {
            $retval = $self->_find_or_create_object( $class, $data, $id_fields );
        };
        if ( $EVAL_ERROR ) {
            croak(qq{Error: Unable to autogenerate $class object: $EVAL_ERROR\n});
        }
        return $retval;
    }
    else {
        croak(qq{Error: $class object not found in database.\n});
    }
}

sub _create_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    # Strip out aggregator identifier components
    $data = $self->_strip_aggregator_info( $class, $data );

    # Strip out any undefined values, which will only create problems
    # during object instantiation.
    my %cleaned_data;
    while ( my ( $key, $value ) = each %{ $data } ) {
        $cleaned_data{ $key } = $value if defined $value;
    }

    # Initial object creation.
    my $obj = $class->new( %cleaned_data );

    # Add authority, namespace to everything _except_ DBEntries with
    # defined term source.
    unless ( UNIVERSAL::isa( $obj, 'Bio::MAGETAB::DatabaseEntry' )
        && defined $obj->get_termSource() ) {
        $obj->set_namespace( $self->get_namespace() );
        $obj->set_authority( $self->get_authority() );
    }

    # Store object in cache for later retrieval.
    $self->get_database()->insert( $obj );

    return $obj;
}

sub _find_or_create_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    my $obj = $self->_query_database( $class, $data, $id_fields );

    # Strip out aggregator identifier components
    $data = $self->_strip_aggregator_info( $class, $data );

    if ( $obj ) {

        # Update the old object as appropriate (FIXME this probably
        # isn't perfect).
        ATTR:
        while ( my ( $attr, $value ) = each %{ $data } ) {

            next ATTR unless ( defined $value );

            my $getter = "get_$attr";
            my $setter = "set_$attr";
            if( defined $obj->$getter ) {

                # FIXME this doesn't work because of the Moose
                # auto_deref behaviour. Inspect the metaclass info to
                # determine constraints?
                my $old = $obj->$getter;
                if ( ref $old eq 'ARRAY' ) {
                    if ( ref $value eq 'ARRAY' ) {
                        foreach my $item ( @$value ) {
                         
                            # If this is a list attribute, add the new value.
                            unless ( first { $_ eq $item } @{ $old } ) {
                                push @{ $old }, $item;
                            }
                        }
                    }
                    else {
                        croak("Error: ArrayRef value expected for $class $attr");
                    }
                }
                else {

                    # Otherwise, we leave it alone (older values take
                    # precedence).
                }
            }
            else {

                # If unset to start with, we set the new value.
                $obj->$setter( $value );
            }
        }

        # Write the changes to the database.
        $self->update( $obj );
    }
    else {

        # Not found; we create a new object.
        $obj = $self->_create_object( $class, $data, $id_fields );
    }

    return $obj;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
