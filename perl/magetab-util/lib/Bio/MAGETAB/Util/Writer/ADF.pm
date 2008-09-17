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

package Bio::MAGETAB::Util::Writer::ADF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

BEGIN { extends 'Bio::MAGETAB::Util::Writer::BaseClass' };

has 'magetab_object'     => ( is         => 'ro',
                              isa        => 'Bio::MAGETAB::ArrayDesign',
                              required   => 1 );

sub _write_header {

    my ( $self ) = @_;

    my $array = $self->get_magetab_object();

    # Just two columns for the header section; main and mapping
    # sections will differ (FIXME check this against the spec).
    $self->set_num_columns( 2 );

    my %single = (
        'Array Design Name'   => 'name',
        'Version'             => 'version',
        'Provider'            => 'provider',
        'Printing Protocol'   => 'printingProtocol',
    );

    # Single elements are straightforward.
    while ( my ( $field, $value ) = each %single ) {
        my $getter = "get_$value";
        $self->_write_line( $field, $array->$getter );
    }

    # Elements pointing to objects need a bit more work.
    my %multi = (
        'termSources' => [
            sub { return ( [ 'Term Source Name',       map { $_->get_name()    } @_ ] ) },
            sub { return ( [ 'Term Source Version',    map { $_->get_version() } @_ ] ) },
            sub { return ( [ 'Term Source File',       map { $_->get_uri()     } @_ ] ) },
        ],
        'technologyType' => [
            sub { return ( [ 'Technology Type',
                             map { $_->get_value()     } @_ ] ) },
            sub { return ( [ 'Technology Type Term Accession Number',
                             map { $_->get_accession() } @_ ] ) },
            sub { return ( [ 'Technology Type Term Source REF',
                             map { $self->_get_type_termsource_name($_) } @_ ] ) },
        ],
        'surfaceType' => [
            sub { return ( [ 'Surface Type',
                             map { $_->get_value()     } @_ ] ) },
            sub { return ( [ 'Surface Type Term Accession Number',
                             map { $_->get_accession() } @_ ] ) },
            sub { return ( [ 'Surface Type Term Source REF',
                             map { $self->_get_type_termsource_name($_) } @_ ] ) },
        ],
        'substrateType' => [
            sub { return ( [ 'Substrate Type',
                             map { $_->get_value()     } @_ ] ) },
            sub { return ( [ 'Substrate Type Term Accession Number',
                             map { $_->get_accession() } @_ ] ) },
            sub { return ( [ 'Substrate Type Term Source REF',
                             map { $self->_get_type_termsource_name($_) } @_ ] ) },
        ],
        'sequencePolymerType' => [
            sub { return ( [ 'Sequence Polymer Type',
                             map { $_->get_value()     } @_ ] ) },
            sub { return ( [ 'Sequence Polymer Type Term Accession Number',
                             map { $_->get_accession() } @_ ] ) },
            sub { return ( [ 'Sequence Polymer Type Term Source REF',
                             map { $self->_get_type_termsource_name($_) } @_ ] ) },
        ],
    );

    # All the complicated stuff gets handled by the dispatch methods
    # in %multi.
    while ( my ( $field, $subs ) = each %multi ) {
        my $getter = "get_$field";
        my @attrs = $array->$getter;
        foreach my $sub ( @$subs ) {
            foreach my $lineref ( $sub->( @attrs ) ) {
                $self->_write_line( @{ $lineref } );
            }
        }
    }

    # Attach all comments to the ArrayDesign.
    foreach my $comment ( $array->get_comments() ) {
        my $field = sprintf("Comment[%s]", $comment->name());
        $self->_write_line( $field, $comment->value() );
    }

    return;
}

sub _write_main {

    my ( $self ) = @_;

    my $array = $self->get_magetab_object();

    # FIXME beware memory issues here; consider creating an iterator
    # to access some of these objects? This would probably need to be
    # in the actual Bio::MAGETAB model, possibly with a file- or
    # db-based backend.
    my @features = grep { UNIVERSAL::isa( $_, 'Bio::MAGETAB::Feature' ) }
                       $array->get_designElements();

    # Figure out which databases are represented.
    my ( @dbs, @groups );
    {
        my (%db_name, %group_name);
        foreach my $rep ( map { $_->get_reporter } @features ) {
            foreach my $db_entry ( $rep->get_databaseEntries() ) {
                my $ts = $db_entry->get_termSource();
                $db_name{ $ts->get_name() }++ if $ts;
            }
            foreach my $group ( $rep->get_groups() ) {
                $group_name{ $group->get_category() }++;
            }
        }
        @dbs    = sort keys %db_name;
        @groups = sort keys %group_name;
    }
    
    # Print out the column headings.
    my @header = (
        'Block Column',
        'Block Row',
        'Column',
        'Row',
        'Reporter Name',
        'Reporter Sequence',
        ( map { "Reporter Database Entry [$_]" } @dbs    ),
        ( map { "Reporter Group [$_]" }          @groups ),
    );
    if ( scalar @groups ) {
        push @header, (
            'Reporter Group Term Source REF',
            'Reporter Group Term Accession Number',
        );
    }
    push @header, (
        'Control Type',
        'Control Type Term Source REF',
        'Control Type Term Accession Number',
    );
    $self->set_num_columns( scalar @header );
    $self->_write_line( @header );

    foreach my $feature ( @features ) {

        # Sort out the basics;
        my @line = map { $feature->$_ }
                       qw( get_blockColumn get_blockRow get_column get_row );
        my $reporter = $feature->get_reporter();
        push @line, $reporter->get_name(), $reporter->get_sequence();

        # Get the database entries, in order.
        my %accession = map {
            my $ts = $_->get_termSource();
            ( $ts ? $ts->get_name() : q{} ) => $_->get_accession();
        } $reporter->get_databaseEntries();
        foreach my $db ( @dbs ) {
            my $acc = $accession{ $db };
            push @line, ( defined $acc ? $acc : q{} );
        }

        # Get the group names, in order.
        my %group = map {
            $_->get_category() => $_->get_value()
        } $reporter->get_groups();
        foreach my $name ( @groups ) {
            my $gr = $group{ $name };
            push @line, ( defined $gr ? $gr : q{} );
        }

        # Group Term Source and Accession, where needed.
        if ( scalar @groups ) {
            my @rep_groups = $reporter->get_groups();
            if ( scalar @rep_groups > 1 ) {
                carp(qq{Warning: Multiple Reporter Group Term Sources/Accessions not supported. }
                   . qq{ADF output only contains these values for "}
                   . $rep_groups[0]->get_category() . qq{"\n})
            }
            push @line, $self->_get_type_termsource_name( $rep_groups[0] );
            my $acc = $rep_groups[0]->get_accession();
            push @line, ( defined $acc ? $acc : q{} );
        }

        # Control Type
        if ( my $ctype = $reporter->get_controlType() ) {
            push @line, $ctype->get_value();
            push @line, $self->_get_type_termsource_name( $ctype );
            my $acc = $ctype->get_accession();
            push @line, ( defined $acc ? $acc : q{} );
        }
        else {
            push @line, (q{}) x 3;
        }
                                  
        $self->_write_line( @line );
    }

    return;
}

sub _write_mapping {

    my ( $self ) = @_;

    my $array = $self->get_magetab_object();

    # FIXME print out the column headings
    $self->_write_line(
        'Composite Element Name',
        'Map2Reporters',
        'Composite Element Database Entry []', # FIXME we need to know what these are!
        'Composite Element Comment',
    );
    
    my @compelems = grep { UNIVERSAL::isa( $_, 'Bio::MAGETAB::CompositeElement' ) }
                       $array->get_designElements();
    foreach my $element ( @compelems ) {
        my @line = (
            $element->get_name(),
            join(';', map { $_->get_name() } $element->get_reporters() ),
            'FIXME',
            $element->get_comments(),
        );

    }
    die;

}

sub write {

    my ( $self ) = @_;

    # FIXME we need to figure out num_columns here, before calling
    # _write_line. This will be the same number for all ADFs.

    $self->_write_line( '[header]' );
    $self->_write_header();

    $self->_write_line( q{} );    # spacer line

    $self->_write_line( '[main]' );
    $self->_write_main();

    $self->_write_line( q{} );    # spacer line

    # It's just easier to default to having a [mapping] section given
    # the way the model fits together.
    $self->_write_line( '[mapping]' );
    $self->_write_mapping();

    return;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
