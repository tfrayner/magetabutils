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

sub _camel_case_tab_delim {

    # Convert a CamelCase class name (without the Bio::MAGETAB::
    # prefix) to a tab-delimited form.
    my ( $self, $str ) = @_;

    $str =~ s/([a-z])([A-Z])/${1}_${2}/g;

    return(lc($str));
}

sub _magetab_to_relname {

    # Given a MAGETAB object, derive the name of the relationship in
    # which it might be found.
    my ( $self, $objclass ) = @_;

    $objclass =~ s/.*:://;
    my $method = $self->_camel_case_tab_delim( $objclass );

    return( $method );
}

sub _magetab_to_attrs_and_idfields {

    # Given a MAGETAB object, retrieve the ID fields defined by the
    # Builder superclass and create an attr hashref suitable for use
    # with _query_database.
    my ( $self, $obj ) = @_;

    # FIXME can this be done more robustly?
    my $method = $self->_magetab_to_relname( ref $obj );
    my ( $class, @id_fields ) = $self->_retrieve_id_fields( $method );

    # Quick assertion to make sure we're on the right track.
    if ( $class ne ref $obj ) {
        confess("Internal Error: unexpected class returned by _retrieve_id_fields.");
    }

    my %attrhash = map { my $getter = "get_$_";
                         $_ => $obj->$getter } @id_fields;
    
    return ( \%attrhash, \@id_fields );
}

sub _query_database {

    my ( $self, $class, $data, $id_fields ) = @_;

    unless ( first { defined $data->{ $_ } } @{ $id_fields } ) {
        my $allowed = join(', ', @{ $id_fields });
        confess(qq{Error: No identifying attributes for $class.}
              . qq{ Must use at least one of the following: $allowed.\n});
    }

    # Add authority, namespace to $id_fields unless $data has a
    # termSource.  Also, TermSources themselves are *always* treated
    # as global in this way.
    my %tmp_fields = map { $_ => 1 } @{ $id_fields }, qw( namespace authority );
    $id_fields = [ keys %tmp_fields ];
    $self->_manage_namespace_authority( $data, $class );

    my ( $cond, $attr );
    FIELD:
    foreach my $field ( @{ $id_fields } ) {

        my $value = $data->{ $field };

        next FIELD if ( ! defined $value || $value eq q{} );

        # Another special case - URI can change in the model
        # between input and output (specifically, a file: prefix
        # may be added). This is copied from
        # Bio::MAGETAB::Types. N.B. dates will need the same
        # treatment if they are used as ID fields.
        if ( $field eq 'uri' ) {
            use URI;
            $value = URI->new( $value );

            # We assume here that thet default URI scheme is "file".
            unless ( $value->scheme() ) {
                $value->scheme('file');
            }
        }
        use Data::Dumper; warn Dumper [ $class, $field ];
        # We need to serialise Bio::MAGETAB objects such that the
        # database knows what to do about them. Note also that this
        # could get quite recursive. (FIXME include a check for cycles
        # here).
        if ( UNIVERSAL::isa($value, 'Bio::MAGETAB::BaseClass') ) {

            # Note that we're not carrying over namespace, authority
            # because some objects (TermSource) might not have them.
            my $relobj = $self->_magetab_query_database( $value );

            # Special cases.
            if ( ( $class eq 'Bio::MAGETAB::Feature'     && $field eq 'array_design' )
              || ( $class eq 'Bio::MAGETAB::Measurement' && $field eq 'object' ) ) {

                # The database and Bio::MAGETAB model all allow n..n
                # for Measurement..Object, but the Builder classes
                # don't work that way. We need a join, as for Feature.
                my $relname = $self->_magetab_to_relname( ref $value );
                $cond->{ "${relname}s.id" } = $relobj->id();
                $attr->{ 'join' } = { "${relname}s" };
            }
            else {

                # The general case.
                $cond->{ $field } = $relobj;
            }
        }
        elsif ( ref $value eq 'ARRAY' ) {
            # No-op; currently this is not needed. There are no
            # Builder ID fields which point to one-to-many or
            # many-to-many relationships.
        }
        else {
            $cond->{ $field } = $value;
        }
    }

    # Actually retrieve the object(s).
    my $dbclass = $class;
    $dbclass =~ s/\A .*:://xms;

    my @objects = $self->get_database->resultset( $dbclass )->search( $cond, $attr );

    # Brief sanity check; identity means identity, i.e. only one object returned.
    if ( scalar @objects > 1 ) {
        my $id = $self->_create_id( $class, $data, $id_fields );
        confess(qq{Error: multiple $class objects found in database. Internal ID was "$id".});
    }

    # Note that we're returning a DBIC row rather than a Bio::MAGETAB object here.
    return $objects[0];
}

sub _get_object {

    # Takes a class name, attr hashref and ID fields arrayref. Returns
    # a Bio::MAGETAB object.
    my ( $self, $class, $data, $id_fields ) = @_;

    if ( my $dbrow = $self->_query_database( $class, $data, $id_fields ) ) {
        return $self->_dbrow_to_magetab( $dbrow );
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

    # Takes a class name, attr hashref and ID fields arrayref. Returns
    # a Bio::MAGETAB object representing a newly-created DB row.
    my ( $self, $class, $data, $id_fields ) = @_;

    # Get a listing of aggregator fields as $is_aggregator
    my ( $cleaned, $is_aggregator ) = $self->_strip_aggregator_info( $class, $data );

    # Make sure our authority and namespace attributes are
    # appropriately managed.
    $self->_manage_namespace_authority( $data, $class );

    # We need to create a DBIC row from the data. This also needs to
    # handle retrieval (but *not* creation) of linked objects. We rely
    # on the consumer of the Builder object to get the object creation
    # order right.
    my %query;
    foreach my $field ( keys %$data ) {

        my $value = $data->{ $field };
        if ( UNIVERSAL::isa($value, 'Bio::MAGETAB::BaseClass' ) ) {

            # Replace this hash value with the appropriate database
            # ID. Note that $field may need to be altered as well,
            # especially for Feature and Measurement.
            my $relobj = $self->_magetab_query_database( $value );

            if ( ( $class eq 'Bio::MAGETAB::Feature'     && $field eq 'array_design' )
              || ( $class eq 'Bio::MAGETAB::Measurement' && $field eq 'object' ) ) {
                my $relname = $self->_magetab_to_relname( ref $value );
                $query{ $relname } = $relobj;
            }
            else {
                $query{ $field } = $relobj;
            }
        }
        elsif ( ref $value eq 'ARRAY' ) {
            
            # We can safely assume that $value is an arrayref of
            # Bio::MAGETAB objects rather than anything else (this was
            # a core design decision when creating the model). We also
            # assume that these are not aggregator identifier
            # components, since there are no multi-style aggregator
            # fields specified by the Builder class.
            my @relobjs;
            foreach my $val ( @$value ) {
                my $relobj = $self->_magetab_query_database( $value );
                push @relobjs, $relobj;
            }

            # According to the DBIx::Class::ResultSet docs this should
            # Just Work.
            $query{ $field } = \@relobjs;
        }
        else {

            # The more general case.
            $query{ $field } = $value;
        }
    }

    # Actually insert the row. FIXME a better error message would dump
    # the data hash as well.
    my $dbclass = $class;
    $dbclass =~ s/\A Bio::MAGETAB:: //xms;
    my $dbrow = $self->get_database->resultset( $dbclass )->create( \%query )
        or confess("Error creating object of class $dbclass");

    # We need to convert the DBIC row object $dbrow into a Bio::MAGETAB
    # object.
    return $self->_dbrow_to_magetab( $dbrow );
}

sub _dbrow_to_magetab {

    my ( $self, $dbrow ) = @_;

    # Convert the DBIC row into a Bio::MAGETAB object. This wants to
    # be a bit clever about how it handles Bio::MAGETAB attributes -
    # rather than instantiating the entire DAG, we'd like a closure
    # method which knows about the attribute data and, when called,
    # replaces itself with an instantiated MAGETAB object.
    my $obj = {};

    my $source = $dbrow->result_source();
    my $class  = $source->source_name();
    $class =~ s/ \A (?:.*::)? /Bio::MAGETAB::/xms;

    foreach my $attr ( $class->meta->get_attribute_list() ) {

        my $dbattr = $self->_camel_case_tab_delim( $attr );

        if ( $source->has_relationship( $dbattr ) ) {

            # Instead of instantiating the related Bio::MAGETAB
            # object(s), we create a closure which can replace itself
            # when called. This helps avoid dumping out the entire
            # database for a simple query.
            my $reltype = $source->relationship_info( $dbattr )->{'accessor'};
            my $setter  = "set_$attr";
            my $getter  = "get_$attr";

            if ( $reltype eq 'single' ) {
                $obj->{ $attr } =
                    sub {
                        $obj->$setter( $self->_dbrow_to_magetab( $dbrow->$dbattr ) );
                        return $obj->$getter;
                    };
            }
            elsif ( $reltype eq 'multi' ) {
                $obj->{ $attr } =
                    sub {
                        $obj->$setter( [ map { $self->_dbrow_to_magetab( $_ ) } $dbrow->$dbattr ] );
                        return $obj->$getter;
                    };
            }
            elsif ( $reltype eq 'filter' ) {

                # This is included for completeness, not actually used
                # in the model at the moment though. FIXME I'm not
                # sure this is exactly what's needed here.
                $obj->{ $attr } = $dbrow->$dbattr;
            }
            else {
                confess(qq{Error: unknown DBIx::Class relationship type "$reltype".});
            }
        }
        elsif ( $source->has_column( $dbattr ) && defined $dbrow->$dbattr ) {

            # Simple attribute. N.B. we may need to handle
            # interconversion between MySQL and Bio::MAGETAB
            # conventions, e.g. for date.
            $obj->{ $attr } = $dbrow->$dbattr;
        }
    }

    # This circumvents the usual type constraint checking, allowing us
    # to use closures instead of instantiated Bio::MAGETAB objects.

    # FIXME this all assumes that the internal structure of the
    # MAGETAB class is a hashref (true at the moment, this is not as
    # certain if people create subclasses though).
    bless $obj, $class;
    
    return $obj;
}

sub update { # TODO

    my ( $self, $obj ) = @_;

    # FIXME ideally we wouldn't use this as part of our standard
    # find/get/create database querying; this is a method provided for
    # Builder API completeness.
    my $dbrow = $self->_magetab_query_database( $obj );

    # FIXME This assumes the MAGETAB $obj is a hashref suitable for
    # passing to _update_dbrow_attributes, which is not necessarily
    # the case.
    $self->_update_dbrow_attributes( $dbrow, $obj );

    return( $self->_dbrow_to_magetab( $dbrow ) );
}

sub _magetab_query_database {

    my ( $self, $obj ) = @_;

    my ( $attr, $id_fields ) = $self->_magetab_to_attrs_and_idfields( $obj );

    return( $self->_query_database( ref $obj, $attr, $id_fields ) );
}

sub _update_dbrow_attributes {

    my ( $self, $dbrow, $data ) = @_;

    # Here we apply the $data hashref to the $dbrow DBIC object, and call $dbrow->update;

    # Note this won't be quite as simple if the $data contains Bio::MAGETAB objects as values.
    my $source = $dbrow->result_source();
    while ( my ( $attr, $value ) = each %$data ) {

        my $dbattr = $self->_camel_case_tab_delim( $attr );

        if ( $source->has_column( $dbattr ) ) {
            $dbrow->set_column( $dbattr, $value );
        }
        elsif ( $source->has_relationship( $dbattr ) ) {

            my $reltype = $source->relationship_info( $dbattr )->{'accessor'};

            if ( $reltype eq 'single' ) {
                my $relobj = $self->_magetab_query_database( $value );
                $dbrow->$dbattr( $relobj );  # FIXME is this the correct way to set relationships?
            }
            elsif ( $reltype eq 'multi' ) {
                my @relobjs = map { $self->_magetab_query_database( ref $_ ) } @{ $value || [] };
                $dbrow->$dbattr( \@relobjs );  # Again, check this FIXME.
            }
            elsif ( $reltype eq 'filter' ) {

                # This is included for completeness, not actually used
                # in the model at the moment though. FIXME I'm not
                # sure this is even needed here; presumably this is
                # caught by has_column anyway.
                $dbrow->set_column( $dbattr, $value );
            }
            else {
                confess(qq{Error: unknown DBIx::Class relationship type "$reltype".});
            }
        }
        else {

            # FIXME is this actually a full-blown error? Currently
            # deactivated as the DBIC schema doesn't correctly handle
            # has_relationship yet.
            
#            confess(sprintf("Warning: %s class has no %s attribute",
#                            $source->source_name(), $dbattr));
        }
    }

    $dbrow->update();
}

sub _find_or_create_object {

    my ( $self, $class, $data, $id_fields ) = @_;

    my $dbrow = $self->_query_database( $class, $data, $id_fields );

    # Strip out aggregator identifier components
    $data = $self->_strip_aggregator_info( $class, $data );

    my $obj;
    if ( $dbrow ) {

        # Update the old dbrow as appropriate.
        $self->_update_dbrow_attributes( $dbrow, $data );

        $obj = $self->_dbrow_to_magetab( $dbrow );
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
