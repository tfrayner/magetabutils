# Copyright 2008-2010 Tim Rayner
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

package Bio::MAGETAB::Util::DBIC::Loader;

use Moose;
use MooseX::FollowPBP;

use Bio::MAGETAB;
use Carp;
use DBI;
use List::Util qw( first );
use English qw( -no_match_vars );

extends 'Bio::MAGETAB::Util::Builder';

has 'database'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Util::DBIC::DB',
                               required   => 1, );

sub _manage_namespace_authority {

    my ( $self, $data, $class ) = @_;

    # Add authority, namespace to everything _except_ DBEntries with
    # defined term source, or TermSource itself.
    if ( UNIVERSAL::isa( $class, 'Bio::MAGETAB::TermSource' ) ) {
        $data->{'namespace'} ||= q{};
        $data->{'authority'} ||= q{};
    }
    elsif ( defined $data->{'termSource'} ) {
        $data->{'namespace'} ||= q{};
        $data->{'authority'} ||= $data->{'termSource'}->get_name();
    }
    else {
        $data->{'namespace'} ||= $self->get_namespace();
        $data->{'authority'} ||= $self->get_authority();
    }
}

sub _query_database {

    my ( $self, $class, $data, $id_fields ) = @_;

    unless ( first { defined $data->{ $_ } } @{ $id_fields } ) {
        my $allowed = join(', ', @{ $id_fields });
        confess(qq{Error: No identifying attributes for $class.}
              . qq{ Must use at least one of the following: $allowed.\n});
    }

    # FIXME do we need $clean_data at all?
    my ( $clean_data, $aggregators )
        = $self->_strip_aggregator_info( $class, $data );

    # Add authority, namespace to $id_fields unless $data has a
    # termSource.  Also, TermSources themselves are *always* treated
    # as global in this way.
    my %tmp_fields = map { $_ => 1 } @{ $id_fields }, qw( namespace authority );
    $id_fields = [ keys %tmp_fields ];
    $self->_manage_namespace_authority( $data, $class );

    my $query;
    FIELD:
    foreach my $field ( @{ $id_fields } ) {

        my $value = $data->{ $field };

        # Don't add aggregator fields to the query (the schema doesn't
        # know about them). FIXME this will change, I hope.
        next FIELD if ( first { $field eq $_ } @{ $aggregators } );

        # Another special case - URI can change in the model
        # between input and output (specifically, a file: prefix
        # may be added). This is copied from
        # Bio::MAGETAB::Types. FIXME date will need the same
        # treatment.
        if ( defined $value && $field eq 'uri' ) {
            use URI;
            $value = URI->new( $value );

            # We assume here that thet default URI scheme is "file".
            unless ( $value->scheme() ) {
                $value->scheme('file');
            }
        }

        # FIXME this is sadly simplistic - we need to serialise
        # Bio::MAGETAB objects such that the database knows what to do
        # about them. Note also that this could get seriously recursive.
        $query->{ $field } = $value;
    }

    # FIXME I think we can add aggregate methods to the ORM and then
    # directly query on such objects here. Note that some classes
    # e.g. Feature will require some special handling (IN
    # array_designs, rather than =array_design, that kind of
    # thing.). Also Measurement needs a search across materials,
    # factor_value and parameter_value.
    my @objects = $self->get_database->resultset( $class )->search( $query );

    # Brief sanity check; identity means identity, i.e. only one object returned.
    if ( scalar @objects > 1 ) {
        my $id = $self->_create_id( $class, $data, $id_fields );
        confess(qq{Error: multiple $class objects found in database. Internal ID was "$id".});
    }

    # Note that we're returning a DBIC row rather than a Bio::MAGETAB object here.
    return $objects[0];
}

sub _get_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    if ( my $row = $self->_query_database( $class, $data, $id_fields ) ) {
        return $self->_dbrow_to_magetab( $row );
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

    # Make sure our authority and namespace attributes are
    # appropriately managed.
    $self->_manage_namespace_authority( $data, $class );

    # FIXME we need to create a DBIC row from the data; the following
    # UNTESTED should in theory work. FIXME a better error message
    # would dump the data hash as well.
    my $row = $self->database->resultset( $class )->create( $data )
        or confess("Error creating object of class $class");

    # We need to convert the DBIC row object $row into a Bio::MAGETAB
    # object.
    return $self->_dbrow_to_magetab( $row );
}

sub _dbrow_to_magetab { # TODO

    my ( $self, $row ) = @_;

    # FIXME Convert the DBIC row into a Bio::MAGETAB object. This
    # wants to be a bit clever about how it handles Bio::MAGETAB
    # attributes - rather than instantiating the entire DAG, we'd like
    # a closure method which knows about the attribute data and, when
    # called, replaces itself with an instantiated MAGETAB object.
    my $obj;
    
    return $obj;
}

sub update { # TODO

    my ( $self, $obj ) = @_;

    # FIXME ideally we wouldn't use this as part of our standard
    # find/get/create database querying; this is a method provided for
    # Builder API completeness.
    
    # FIXME we really need to _query_database,
    # _update_dbrow_attributes, _dbrow_to_magetab and return the
    # result.
}

sub _update_dbrow_attributes { # TODO

    my ( $self, $row, $data ) = @_;

    # FIXME just apply the $data hashref to the $row DBIC object, and call $row->update;

    # Note this won't be quite as simple if the $data contains Bio::MAGETAB objects as values.

    $row->update();
}

sub _find_or_create_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    my $row = $self->_query_database( $class, $data, $id_fields );

    # Strip out aggregator identifier components
    $data = $self->_strip_aggregator_info( $class, $data );

    my $obj;
    if ( $row ) {

        # Update the old object as appropriate. FIXME this needs
        # writing to take a DBIC::Row object.
        $self->_update_dbrow_attributes( $row, $data );

        $obj = $self->_dbrow_to_magetab( $obj );
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

=head1 NAME

Bio::MAGETAB::Util::DBIC::Loader - A DBIx::Class storage loader class
used to track Bio::MAGETAB object creation and insertion into a
relational database.

=head1 SYNOPSIS

 require Bio::MAGETAB::Util::Reader;
 require Bio::MAGETAB::Util::DBIC::DB;
 require Bio::MAGETAB::Util::DBIC::Loader;
 
 my $reader = Bio::MAGETAB::Util::Reader->new({
     idf => $idf
 });
 
 # Connect to the database.
 my $db = Bio::MAGETAB::Util::DBIC::DB->connect("dbi:SQLite:$db_file");
  
 # If this is a new database, deploy the schema.
 unless ( -e $db_file ) {
     $db->deploy();
 }
 
 my $builder = Bio::MAGETAB::Util::DBIC::Loader->new({
     database => $db,
 });
 
 $reader->set_builder( $builder );
 
 # Read objects into the database.
 $reader->parse();

=head1 DESCRIPTION

This module is a Builder subclass which uses a relational database
backend to track object creation, rather than the simple hash
reference mechanism used by Builder.

=head1 ATTRIBUTES

See the L<Builder|Bio::MAGETAB::Util::Builder> class for documentation on the superclass
attributes.

=over 2

=item database

The internal store to use for object lookups. This must be a
Bio::MAGETAB::Util::DBIC::DB schema object.

=back

=head1 METHODS

See the L<Builder|Bio::MAGETAB::Util::Builder> class for documentation on the superclass
methods.

=head1 CAVEATS

In contrast to the Tangram DB and Loader classes, this
DBIx::Class-based backend is not an object persistence
mechanism. Objects are instantiated completely separately from their
copies in the database, and no attempt is made to keep the database
synchronised with in-memory objects.

=head1 SEE ALSO

L<Bio::MAGETAB::Util::Reader>
L<Bio::MAGETAB::Util::Builder>
L<Bio::MAGETAB::Util::DBIC::DB>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
