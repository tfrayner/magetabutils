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

package Bio::MAGETAB::Util::Builder;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB;
use Carp;
use List::Util qw( first );
use English qw( -no_match_vars );

has 'authority'           => ( is         => 'rw',
                               isa        => 'Str',
                               default    => q{},
                               required   => 1 );

has 'namespace'           => ( is         => 'rw',
                               isa        => 'Str',
                               default    => q{},
                               required   => 1 );

has 'database'            => ( is         => 'rw',
                               isa        => 'HashRef',
                               default    => sub { {} },
                               required   => 1 );

has 'magetab'             => ( is         => 'ro',
                               isa        => 'Bio::MAGETAB',
                               default    => sub { Bio::MAGETAB->new() },
                               required   => 1 );

has 'relaxed_parser'      => ( is         => 'rw',
                               isa        => 'Bool',
                               default    => 0,
                               required   => 1 );

sub update {

    # Empty stub method; updates are not required when the objects are
    # all held in scope by the database hashref. This method is
    # overridden in persistence subclasses dealing with
    # e.g. relational databases.

    1;
}

sub _create_id {

    my ( $self, $class, $data, $id_fields ) = @_;

    unless ( first { defined $data->{ $_ } } @{ $id_fields } ) {
        my $allowed = join(', ', @{ $id_fields });
        confess(qq{Error: No identifying attributes for $class.}
              . qq{ Must use at least one of the following: $allowed.\n});
    }

    my $id = join(q{; }.chr(0), map { $data->{$_} || q{} } sort @{ $id_fields });

    # This really should never happen.
    unless ( $id ) {
        confess("Error: Null object ID in class $class.\n");
    }

    return $id;
}

sub _update_object_attributes {

    my ( $self, $obj, $data ) = @_;

    my $class = $obj->meta()->name();

    ATTR:
    while ( my ( $attr, $value ) = each %{ $data } ) {

        next ATTR unless ( defined $value );

        my $getter = "get_$attr";
        my $setter = "set_$attr";
        my $has_a  = "has_$attr";

        # Object either must have attr or has a predicate method.
        if( ! UNIVERSAL::can( $obj, $has_a ) || $obj->$has_a ) {

            my $attr_obj = $obj->meta->find_attribute_by_name( $attr );
            my $type = $attr_obj->type_constraint()->name();

            if ( $type =~ /\A ArrayRef/xms ) {
                if ( ref $value eq 'ARRAY' ) {
                    my @old = $obj->$getter;
                    foreach my $item ( @$value ) {
                         
                        # If this is a list attribute, add the new value.
                        unless ( first { $_ eq $item } @old ) {
                            push @old, $item;
                        }
                    }
                    $obj->$setter( \@old );
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
}

sub _get_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    my $id = $self->_create_id( $class, $data, $id_fields );

    # Strip out aggregator identifier components.
    $data = $self->_strip_aggregator_info( $class, $data );

    if ( my $retval = $self->get_database()->{ $class }{ $id } ) {
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
            croak(qq{Error: Unable to autogenerate $class with ID "$id": $EVAL_ERROR\n});
        }
        return $retval;
    }
    else {
        croak(qq{Error: $class with ID "$id" is unknown.\n});
    }
}

sub _create_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    my $id = $self->_create_id( $class, $data, $id_fields );

    # Strip out aggregator identifier components
    $data = $self->_strip_aggregator_info( $class, $data );

    # Strip out any undefined values, which will only create problems
    # during object instantiation.
    my %cleaned_data;
    while ( my ( $key, $value ) = each %{ $data } ) {
        $cleaned_data{ $key } = $value if defined $value;
    }

    # Initial object creation. Namespace, authority can both be
    # overridden by $data, hence the order here. Note that we make no
    # special allowance for "global" objects such as DatabaseEntry
    # here; see Builder subclasses for smarter handling.
    my $obj = $class->new(
        'namespace' => $self->get_namespace(),
        'authority' => $self->get_authority(),
        %cleaned_data,
    );

    # Store object in cache for later retrieval.
    $self->get_database()->{ $class }{ $id } = $obj;

    return $obj;
}

sub _find_or_create_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    my $id = $self->_create_id( $class, $data, $id_fields );

    # Strip out aggregator identifier components
    $data = $self->_strip_aggregator_info( $class, $data );

    my $obj;
    if ( $obj = $self->get_database()->{ $class }{ $id } ) {

        # Update the old object as appropriate.
        $self->_update_object_attributes( $obj, $data );
    }
    else {

        $obj = $self->_create_object( $class, $data, $id_fields );
    }

    return $obj;
}

# Hash of method types (find_or_create_*, get_*), pointing to an
# arrayref indicating the class to instantiate and the attributes to
# use in defining a unique internal identifier.
my %method_map = (
    'investigation'   => [ 'Bio::MAGETAB::Investigation',
                           qw( title ) ],

    'termsource'      => [ 'Bio::MAGETAB::TermSource',
                           qw( name ) ],

    'controlled_term' => [ 'Bio::MAGETAB::ControlledTerm',
                           qw( category value ) ],

    'database_entry'  => [ 'Bio::MAGETAB::DatabaseEntry',
                           qw( accession termSource ) ],

    'term_source'     => [ 'Bio::MAGETAB::TermSource',
                           qw( name ) ],

    'factor'          => [ 'Bio::MAGETAB::Factor',
                           qw( name ) ],

    'factor_value'    => [ 'Bio::MAGETAB::FactorValue',
                           qw( factor term measurement ) ],

    'measurement'     => [ 'Bio::MAGETAB::Measurement',
                           qw( measurementType value minValue maxValue unit object ) ],

    'sdrf'            => [ 'Bio::MAGETAB::SDRF',
                           qw( uri ) ],

    'sdrf_row'        => [ 'Bio::MAGETAB::SDRFRow',
                           qw( rowNumber sdrf ) ],

    'protocol'        => [ 'Bio::MAGETAB::Protocol',
                           qw( name ) ],

    'protocol_application' => [ 'Bio::MAGETAB::ProtocolApplication',
                           qw( protocol date edge ) ],

    'parameter_value' => [ 'Bio::MAGETAB::ParameterValue',
                           qw( parameter measurement protocol_application ) ],

    'protocol_parameter' => [ 'Bio::MAGETAB::ProtocolParameter',
                           qw( name protocol ) ],

    'contact'         => [ 'Bio::MAGETAB::Contact',
                           qw( firstName midInitials lastName ) ],

    'publication'     => [ 'Bio::MAGETAB::Publication',
                           qw( title ) ],

    'source'          => [ 'Bio::MAGETAB::Source',
                           qw( name ) ],

    'sample'          => [ 'Bio::MAGETAB::Sample',
                           qw( name ) ],

    'extract'         => [ 'Bio::MAGETAB::Extract',
                           qw( name ) ],

    'labeled_extract' => [ 'Bio::MAGETAB::LabeledExtract',
                           qw( name ) ],

    'edge'            => [ 'Bio::MAGETAB::Edge',
                           qw( inputNode outputNode ) ],

    'array_design'    => [ 'Bio::MAGETAB::ArrayDesign',
                           qw( name ) ],

    'assay'           => [ 'Bio::MAGETAB::Assay',
                           qw( name ) ],

    'data_acquisition' => [ 'Bio::MAGETAB::DataAcquisition',
                           qw( name ) ],

    'normalization'    => [ 'Bio::MAGETAB::Normalization',
                           qw( name ) ],

    'data_file'        => [ 'Bio::MAGETAB::DataFile',
                           qw( uri ) ],

    'data_matrix'      => [ 'Bio::MAGETAB::DataMatrix',
                           qw( uri ) ],

    'matrix_column'    => [ 'Bio::MAGETAB::MatrixColumn',
                           qw( columnNumber data_matrix ) ],

    'matrix_row'       => [ 'Bio::MAGETAB::MatrixRow',
                           qw( rowNumber data_matrix ) ],

    'feature'          => [ 'Bio::MAGETAB::Feature',
                           qw( blockCol blockRow col row array_design ) ],

    'reporter'          => [ 'Bio::MAGETAB::Reporter',
                           qw( name ) ],

    'composite_element' => [ 'Bio::MAGETAB::CompositeElement',
                           qw( name ) ],

    'comment'           => [ 'Bio::MAGETAB::Comment',
                           qw( name value object ) ],

);

# Arguments which aren't actual object attributes, but yet still
# contribute to its identity. Typically this is all about aggregation.
my %aggregator_map = (
    'Bio::MAGETAB::SDRFRow'              => [ qw( sdrf ) ],
    'Bio::MAGETAB::Comment'              => [ qw( object ) ],
    'Bio::MAGETAB::ProtocolApplication'  => [ qw( edge ) ],
    'Bio::MAGETAB::ParameterValue'       => [ qw( protocol_application ) ],
    'Bio::MAGETAB::MatrixColumn'         => [ qw( data_matrix ) ],
    'Bio::MAGETAB::MatrixRow'            => [ qw( data_matrix ) ],
    'Bio::MAGETAB::Measurement'          => [ qw( object ) ],
    'Bio::MAGETAB::Feature'              => [ qw( array_design ) ],
);

sub _strip_aggregator_info {

    my ( $self, $class, $data ) = @_;

    my %aux = map { $_ => 1 } @{ $aggregator_map{ $class } || [] };

    my ( %new_data, @discarded );
    while ( my ( $key, $value ) = each %$data ) {
        if ( $aux{ $key } ) {
            push @discarded, $key;
        }
        else {
            $new_data{ $key } = $value;
        }
    }

    return wantarray ? ( \%new_data, \@discarded ) : \%new_data;
}

{
    no strict qw(refs);
    while ( my( $item, $info ) = each %method_map ) {

        my ( $class, @id_fields ) = @{ $info };

        # Getter only; if the object is unfound, fail unless we're
        # being cool about it.
        *{"get_${item}"} = sub {
            my ( $self, $data ) = @_;

            return $self->_get_object(
                $class,
                $data,
                \@id_fields,
            );
	};

        # Flexible method to update a previous object or create a new one.
        *{"find_or_create_${item}"} = sub {
            my ( $self, $data ) = @_;

            return $self->_find_or_create_object(
                $class,
                $data,
                \@id_fields,
            );
        };

        # Sometimes we just want to instantiate whatever (ProtocolApps, ParamValues).
        *{"create_${item}"} = sub {
            my ( $self, $data ) = @_;

            return $self->_create_object(
                $class,
                $data,
                \@id_fields,
            );
        }
    }
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
