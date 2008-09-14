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

package Bio::MAGETAB::Util::Writer::IDF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;
use List::Util qw( max );

BEGIN { extends 'Bio::MAGETAB::Util::Writer::BaseClass' };

has 'magetab_object'     => ( is         => 'ro',
                              isa        => 'Bio::MAGETAB::Investigation',
                              required   => 1 );

sub _collapse_contacts {

    my ( $self, @contacts ) = @_;

    # Given a list of Contact objects, collapse them into a list of
    # arrayrefs suitable for passing to $self->_write_line()

    # This is just a convenience hash to store data
    my %list = (
        'value'         => [ 'Person Roles' ],
        'termSource'    => [ 'Person Roles Term Source REF' ],
        'accession'     => [ 'Person Roles Term Accession Number' ],
    );
    foreach my $contact ( @contacts ) {

        # Multiple Role terms can be specified, separated by semicolons.
        push @{ $list{'value'} },
            ( join(';', map { $_->get_value() } $contact->get_roles() ) || q{} );

        # Unfortunately as of the v1.1 specification, multiple
        # TermSources and Accessions are a no-no. That makes this part
        # a bit more complicated than it needs to be.
        my (%ts_test, %acc_test, $ts1, $acc1);
        foreach my $role ( $contact->get_roles() ) {

            my $ts  = $role->get_termSource();
            my $acc = $role->get_accession();

            # Only store the first one of each.
            $ts1  ||= $ts;
            $acc1 ||= $acc;

            $ts_test{  $ts  } = $ts  if $ts;
            $acc_test{ $acc } = $acc if $acc;
        }

        # Warn where the model isn't quite in line with the spec.
        if ( scalar grep { defined $_ } values %ts_test > 1 ) {
            carp("Warning: Multiple Role Term Sources (unsupported by MAGE-TAB format).");
        }
        if ( scalar grep { defined $_ } values %acc_test > 1 ) {
            carp("Warning: Multiple Role Term Accessions (unsupported by MAGE-TAB format).");
        }

        # Just output the first TermSource and/or Accession we encountered.
        push @{ $list{'termSource'} }, ( $ts1 ? $ts1->get_name() : q{} );
        push @{ $list{'accession'} },  ( $acc1 || q{} );
    }

    # This will be the eventual output order of the lines.
    return ( $list{'value'}, $list{'termSource'}, $list{'accession'} );
}

sub _get_thing_type {
    my ( $self, $thing ) = @_;
    my $type;
    if ( UNIVERSAL::can( $thing, 'get_type' ) ) {
        $type = $thing->get_type();
    }
    elsif ( UNIVERSAL::can( $thing, 'get_status' ) ) {
        $type = $thing->get_status();
    }
    else {
        confess("Error: Cannot find a ControlledVocab-linked attribute for "
                    . blessed $thing );
    }
    return $type;
}

sub _get_thing_type_value {
    my ( $self, $thing ) = @_;
    my $type = $self->_get_thing_type( $thing );
    return $type ? $type->get_value() : q{};
}

sub _get_thing_type_accession {
    my ( $self, $thing ) = @_;
    my $type = $self->_get_thing_type( $thing );
    return $type ? $type->get_accession() : q{};
}

sub _get_thing_type_termsource_name {
    my ( $self, $thing ) = @_;
    my $type = $self->_get_thing_type( $thing );
    return $self->_get_type_termsource_name($type);
}

sub _get_type_termsource_name {
    my ( $self, $type ) = @_;
    my $ts = $type ? $type->get_termSource() : undef;
    return $ts ? $ts->get_name() : q{};
}

sub write {

    my ( $self ) = @_;

    my $fh  = $self->get_filehandle();
    my $inv = $self->get_magetab_object();

    my @single = qw( title
                     description
                     date
                     publicReleaseDate );

    # FIXME check these field names against the spec!
    my @other_comments;
    my %multi = (
        'contacts' => [
            sub { return ( [ 'Person Last Name',     map { $_->get_lastName()     } @_ ] ) },
            sub { return ( [ 'Person First Name',    map { $_->get_firstName()    } @_ ] ) },
            sub { return ( [ 'Person Mid Initials',  map { $_->get_midInitials()  } @_ ] ) },
            sub { return ( [ 'Person Email',         map { $_->get_email()        } @_ ] ) },
            sub { return ( [ 'Person Affiliation',   map { $_->get_affiliation()  } @_ ] ) },
            sub { return ( [ 'Person Phone',         map { $_->get_phone()        } @_ ] ) },
            sub { return ( [ 'Person Fax',           map { $_->get_fax()          } @_ ] ) },
            sub { return ( [ 'Person Address',       map { $_->get_address()      } @_ ] ) },
            sub { $self->_collapse_contacts( @_ ); },
            sub { push @other_comments, map { $_->get_comments() } @_ },
        ],
        'factors' => [
            sub { return ( [ 'Experimental Factor Name', map { $_->get_name() } @_ ] ) },
            sub { return ( [ 'Experimental Factor Type',
                             map { $self->_get_thing_type_value($_) } @_ ] ) },
            sub { return ( [ 'Experimental Factor Term Source REF',
                             map { $self->_get_thing_type_termsource_name($_) } @_ ] ) },
            sub { return ( [ 'Experimental Factor Term Accession Number',
                             map { $self->_get_thing_type_accession($_) } @_ ] ) },
        ],
        'sdrfs' => [
            sub { return ( [ 'SDRF Files', map { $_->get_uri()        } @_ ] ) },
        ],
        'protocols' => [
            sub { return ( [ 'Protocol Name',        map { $_->get_name()     } @_ ] ) },
            sub { return ( [ 'Protocol Description', map { $_->get_text()     } @_ ] ) },
            sub { return ( [ 'Protocol Software',    map { $_->get_software() } @_ ] ) },
            sub { return ( [ 'Protocol Hardware',    map { $_->get_hardware() } @_ ] ) },
            sub { return ( [ 'Protocol Contact',     map { $_->get_contact()  } @_ ] ) },
            sub { return ( [ 'Protocol Type',
                             map { $self->_get_thing_type_value($_) } @_ ] ) },
            sub { return ( [ 'Protocol Term Source REF',
                             map { $self->_get_thing_type_termsource_name($_) } @_ ] ) },
            sub { return ( [ 'Protocol Term Accession Number',
                             map { $self->_get_thing_type_accession($_) } @_ ] ) },
        ],
        'publications' => [
            sub { return ( [ 'Publication Title',       map { $_->get_title()      } @_ ] ) },
            sub { return ( [ 'Publication Author List', map { $_->get_authorList() } @_ ] ) },
            sub { return ( [ 'PubMed ID',               map { $_->get_pubMedID()   } @_ ] ) },
            sub { return ( [ 'Publication DOI',         map { $_->get_DOI()        } @_ ] ) },
            sub { return ( [ 'Publication Status',
                             map { $self->_get_thing_type_value($_) } @_ ] ) },
            sub { return ( [ 'Publication Status Term Source REF',
                             map { $self->_get_thing_type_termsource_name($_) } @_ ] ) },
            sub { return ( [ 'Publication Status Term Accession Number',
                             map { $self->_get_thing_type_accession($_) } @_ ] ) },
        ],
        'termSources' => [
            sub { return ( [ 'Term Source Name',       map { $_->get_name()    } @_ ] ) },
            sub { return ( [ 'Term Source Version',    map { $_->get_version() } @_ ] ) },
            sub { return ( [ 'Term Source File',       map { $_->get_uri()     } @_ ] ) },
        ],
        'designTypes' => [
            sub { return ( [ 'Experimental Design',
                             map { $_->get_value()     } @_ ] ) },
            sub { return ( [ 'Experimental Design Term Accession Number',
                             map { $_->get_accession() } @_ ] ) },
            sub { return ( [ 'Experimental Design Term Source REF',
                             map { $self->_get_type_termsource_name($_) } @_ ] ) },
        ],
        'normalizationTypes' => [
            sub { return ( [ 'Normalization Type',
                             map { $_->get_value()     } @_ ] ) },
            sub { return ( [ 'Normalization Term Accession Number',
                             map { $_->get_accession() } @_ ] ) },
            sub { return ( [ 'Normalization Term Source REF',
                             map { $self->_get_type_termsource_name($_) } @_ ] ) },
        ],
        'replicateTypes' => [
            sub { return ( [ 'Replicate Type',
                             map { $_->get_value()     } @_ ] ) },
            sub { return ( [ 'Replicate Term Accession Number',
                             map { $_->get_accession() } @_ ] ) },
            sub { return ( [ 'Replicate Term Source REF',
                             map { $self->_get_type_termsource_name($_) } @_ ] ) },
        ],
        'qualityControlTypes' => [
            sub { return ( [ 'Quality Control Type',
                             map { $_->get_value()     } @_ ] ) },
            sub { return ( [ 'Quality Control Term Accession Number',
                             map { $_->get_accession() } @_ ] ) },
            sub { return ( [ 'Quality Control Term Source REF',
                             map { $self->_get_type_termsource_name($_) } @_ ] ) },
        ],
    );

    # We want a regular table, so figure out how many columns we will
    # need.
    my @objcounts = map {
        my $getter = "get_$_";
        scalar $inv->$getter;
    } keys %multi;
    $self->set_num_columns( 1 + max @objcounts );

    # Single elements are straightforward.
    foreach my $field ( @single ) {
        my $getter = "get_$field";
        $self->_write_line( $field, $inv->$getter );
    }

    # All the complicated stuff gets handled by the dispatch methods
    # in %multi.
    while ( my ( $field, $subs ) = each %multi ) {
        my $getter = "get_$field";
        my @attrs = $inv->$getter;
        foreach my $sub ( @$subs ) {
            foreach my $lineref ( $sub->( @attrs ) ) {
                $self->_write_line( @{ $lineref } );
            }
        }
    }

    # All comments on IDF-related classes are dumped into the IDF at
    # the end. FIXME consider maybe inserting them at the appropriate
    # places? Subsequent parsing won't preserve these locations though.
    foreach my $comment ( $inv->get_comments(), @other_comments ) {
        my $field = sprintf("Comment[%s]", $comment->name());
        $self->_write_line( $field, $comment->value() );
    }
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
