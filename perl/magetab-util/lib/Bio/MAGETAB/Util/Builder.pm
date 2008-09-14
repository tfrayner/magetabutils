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

has 'object_cache'        => ( is         => 'rw',
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

sub _create_object {

    my ( $self, $class, $id, $data ) = @_;

    # Strip out any undefined values, which will only create problems
    # during object instantiation.
    my %cleaned_data;
    while ( my ( $key, $value ) = each %{ $data } ) {
        $cleaned_data{ $key } = $value if defined $value;
    }

    # Initial object creation. Namespace, authority can both be
    # overridden by $data, hence the order here.
    my $obj = $class->new(
        'namespace' => $self->get_namespace(),
        'authority' => $self->get_authority(),
        %cleaned_data,
    );

    # FIXME are we sure we want to store these in the cache here?
    # ProtocolApp/ParamValue not terribly useful... (but on the other
    # hand, objects created should be found later by get_* and
    # find_or_create_*)
    $self->get_object_cache()->{ $class }{ $id } = $obj;

    return $obj;
}

sub _find_or_create_object {

    my ( $self, $class, $id, $data ) = @_;

    unless ( defined $id ) {
        confess("Error: undefined object ID.\n");
    }

    my $obj;
    if ( $obj = $self->get_object_cache()->{ $class }{ $id } ) {

        # Update the old object as appropriate (FIXME this probably
        # isn't perfect).
        ATTR:
        while ( my ( $attr, $value ) = each %{ $data } ) {

            next ATTR unless ( defined $value );

            my $getter = "get_$attr";
            my $setter = "set_$attr";
            if( defined $obj->$getter ) {
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
    }
    else {

        $obj = $self->_create_object( $class, $id, $data );
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
                           qw( type value minValue maxValue unit ) ],

    'sdrf'            => [ 'Bio::MAGETAB::SDRF',
                           qw( uri ) ],

    'sdrf_row'        => [ 'Bio::MAGETAB::SDRFRow',
                           qw( rowNumber ) ],

    'protocol'        => [ 'Bio::MAGETAB::Protocol',
                           qw( name ) ],

    'protocol_application' => [ 'Bio::MAGETAB::ProtocolApplication',
                           qw( protocol date ) ],

    'parameter_value' => [ 'Bio::MAGETAB::ParameterValue',
                           qw( parameter measurement ) ],

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

    # FIXME consider using the data matrix object as part of the internal ID?
    'matrix_column'    => [ 'Bio::MAGETAB::MatrixColumn',
                           qw( columnNumber ) ],

    'matrix_row'       => [ 'Bio::MAGETAB::MatrixRow',
                           qw( rowNumber ) ],

    'feature'          => [ 'Bio::MAGETAB::Feature',
                           qw( blockColumn blockRow column row ) ],

    'reporter'          => [ 'Bio::MAGETAB::Reporter',
                           qw( name ) ],

    'composite_element' => [ 'Bio::MAGETAB::CompositeElement',
                           qw( name ) ],

    'comment'           => [ 'Bio::MAGETAB::Comment',
                           qw( name value ) ],

);

# Arguments which aren't actual object attributes, but yet still
# contribute to its identity.
my %auxilliary_map = (
    'sdrf_row'             => qw( sdrf ),
    'comment'              => qw( object ),
    'protocol_application' => qw( edge ),
    'parameter_value'      => qw( protocol_application ),
    'matrix_column'        => qw( data_matrix ),
    'matrix_row'           => qw( data_matrix ),
);

sub _strip_auxilliary_info {

    my ( $self, $item, $data ) = @_;

    my %aux = map { $_ => 1 } ( $auxilliary_map{ $item } || [] );

    my %new_data;
    while ( my ( $key, $value ) = each %$data ) {
        $new_data{ $key } = $value unless $aux{ $key };
    }

    return \%new_data;
}

sub _create_id {

    my ( $self, $data, $fields ) = @_;

    return join(q{; }.chr(0), map { $data->{$_} || q{} } sort @$fields);
}

{
    no strict qw(refs);
    while ( my( $item, $info ) = each %method_map ) {

        my ( $class, @id_fields ) = @{ $info };

        # Getter only; if the object is unfound, fail unless we're
        # being cool about it.
        *{"get_${item}"} = sub {
            my ( $self, $data ) = @_;

            my $id = $self->_create_id( $data, \@id_fields );

            # Strip out auxilliary identifier components.
            $data = $self->_strip_auxilliary_info( $item, $data );

            if ( my $retval = $self->get_object_cache()->{ $class }{ $id } ) {
                return $retval;
            }
            elsif ( $self->get_relaxed_parser() ) {

                # If we're relaxing constraints, try and create an
                # empty object (in most cases this will probably fail
                # anyway).
                my $retval;
                eval {
                    $retval = $self->_find_or_create_object( $class, $id, $data );
                };
                if ( $EVAL_ERROR ) {
                    croak(qq{Error: Unable to autogenerate $class with ID "$id": $EVAL_ERROR\n});
                }
                return $retval;
            }
            else {
                croak(qq{Error: $class with ID "$id" is unknown.\n});
            }
	};

        # Flexible method to update a previous object or create a new one.
        *{"find_or_create_${item}"} = sub {
            my ( $self, $data ) = @_;

            unless ( first { defined $data->{ $_ } } @id_fields ) {
                my $allowed = join(', ', @id_fields);
                confess(qq{Error: No identifying attributes for $class.}
                      . qq{ Must use at least one of the following: $allowed.\n});
            }

            my $id = $self->_create_id( $data, \@id_fields );

            # Strip out auxilliary identifier components
            $data = $self->_strip_auxilliary_info( $item, $data );

            return $self->_find_or_create_object(
                $class,
                $id,
                $data,
            );
        };

        # Sometimes we just want to instantiate whatever (ProtocolApps, ParamValues).
        *{"create_${item}"} = sub {
            my ( $self, $data ) = @_;

            unless ( first { defined $data->{ $_ } } @id_fields ) {
                my $allowed = join(', ', @id_fields);
                confess(qq{Error: No identifying attributes for $class.}
                      . qq{ Must use at least one of the following: $allowed.\n});
            }

            my $id = $self->_create_id( $data, \@id_fields );

            # Strip out auxilliary identifier components
            $data = $self->_strip_auxilliary_info( $item, $data );

            return $self->_create_object(
                $class,
                $id,
                $data,
            );
        }
    }
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
