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

package Bio::MAGETAB::Util::Reader::Builder;

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
                               isa        => 'Int',
                               default    => 0,
                               required   => 1 );

sub _create_object {

    my ( $self, $class, $id, $data ) = @_;

    # Initial object creation. Namespace, authority can both be
    # overridden by $data, hence the order here.
    my $obj = $class->new(
        'namespace' => $self->get_namespace(),
        'authority' => $self->get_authority(),
        %{ $data },
    );

    # FIXME are we sure we want to store these in the cache here?
    # ProtocolApp/ParamValue not terribly useful...
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
        while ( my ( $attr, $value ) = each %{ $data } ) {
            my $getter = "get_$attr";
            my $setter = "set_$attr";
            if( defined $obj->$getter ) {
                my $old = $obj->$getter;
                if ( ref $old eq 'ARRAY' ) {

                    # If this is a list attribute, add the new value.
                    unless ( first { $_ eq $value } @{ $old } ) {
                        push @{ $old }, $value;
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
    'termsource'      => [ 'Bio::MAGETAB::TermSource',
                           qw( name ) ],

    'controlled_term' => [ 'Bio::MAGETAB::ControlledTerm',
                           qw( category value ) ],

    'term_source'     => [ 'Bio::MAGETAB::TermSource',
                           qw( name ) ],

    'factor'          => [ 'Bio::MAGETAB::Factor',
                           qw( name ) ],

    'factor_value'    => [ 'Bio::MAGETAB::FactorValue',
                           qw( factor value measurement ) ],

    'protocol'        => [ 'Bio::MAGETAB::Protocol',
                           qw( name ) ],

    # FIXME other things needed here... or special-case this not to reuse old objects.
    'protocol_application' => [ 'Bio::MAGETAB::ProtocolApplication',
                           qw( protocol ) ],

    'parameter'       => [ 'Bio::MAGETAB::ProtocolParameter',
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

    'data_file'        => [ 'Bio::MAGETAB::DataFile',
                           qw( uri ) ],

    'data_matrix'      => [ 'Bio::MAGETAB::DataMatrix',
                           qw( uri ) ],

    'matrix_column'    => [ 'Bio::MAGETAB::MatrixColumn',
                           qw( columnNumber ) ],

    'matrix_row'       => [ 'Bio::MAGETAB::MatrixRow',
                           qw( rowNumber ) ],

    'reporter'          => [ 'Bio::MAGETAB::Reporter',
                           qw( name ) ],

    'composite_element' => [ 'Bio::MAGETAB::CompositeElement',
                           qw( name ) ],

);

{
    no strict qw(refs);
    while ( my( $item, $info ) = each %method_map ) {

        my ( $class, @id_fields ) = @{ $info };

        # Getter only; if the object is unfound, fail unless we're
        # being cool about it.
        *{"get_${item}"} = sub {
            my ( $self, @id_parts ) = @_;

            my $id = join(chr(0), sort @id_parts);

            if ( my $retval = $self->get_object_cache()->{ $class }{ $id } ) {
                return $retval;
            }
            elsif ( $self->get_relaxed_parser() ) {

                # If we're relaxing constraints, try and create an
                # empty object (in most cases this will probably fail
                # anyway).
                my $retval;
                eval {
                    my $data = {};

                    # Simplest (and most useful) case where the ID is
                    # constructed from only one field. FIXME this may
                    # be generalizable using @id_parts, but ordering
                    # may end up being unconstrained so this may not
                    # work.
                    if ( scalar @id_fields == 1 ) {
                        $data->{ $id_fields[0] } = $id;
                    }

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

            foreach my $field ( @id_fields ) {
                unless ( defined $data->{ $field } ) {
                    confess(qq{Error: No "$field" attribute for $class.\n});
                }
            }

            my $id = join(chr(0), map { $data->{$_} } sort @id_fields);

            return $self->_find_or_create_object(
                $class,
                $id,
                $data,
            );
        };

        # Sometimes we just want to instantiate whatever (ProtocolApps, ParamValues).
        *{"create_${item}"} = sub {
            my ( $self, $data ) = @_;

            foreach my $field ( @id_fields ) {
                unless ( defined $data->{ $field } ) {
                    confess(qq{Error: No "$field" attribute for $class.\n});
                }
            }

            my $id = join(chr(0), map { $data->{$_} } sort @id_fields);

            return $self->_create_object(
                $class,
                $id,
                $data,
            );
        }
    }
}

sub find_or_create_comment {

    my ( $self, $data ) = @_;

    my $class = 'Bio::MAGETAB::Comment';

    foreach my $field ( qw( name value ) ) {
        unless ( defined $data->{ $field } ) {
            confess(qq{Error: No "$field" attribute for $class.\n});
        }
    }

    # Object here is the object to which we're attaching the
    # comment. FIXME this may need a rethink when we come to the SDRF.
    my $id = join(chr(0), map { $data->{$_} || q{} } sort qw( name value object ) );

    return $self->_find_or_create_object(
        $class,
        $id,
        {
            'name'  => $data->{'name'},
            'value' => $data->{'value'},
        },
    );
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
