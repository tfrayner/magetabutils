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

BEGIN { extends 'Bio::MAGETAB::Util::Writer::Tabfile' };

has 'magetab_object'      => ( is         => 'ro',
                               isa        => 'Bio::MAGETAB::ArrayDesign',
                               required   => 1 );

has 'cached_mapping_flag' => ( is         => 'rw',
                               isa        => 'Bool',
                               predicate  => 'has_cached_mapping_flag',
                               required   => 0 );

sub _write_header {

    my ( $self ) = @_;

    my $array = $self->get_magetab_object();

    # Just two columns for the header section; main and mapping
    # sections will differ (FIXME check this against the spec).
    $self->set_num_columns( 2 );
    $self->_write_line( '[header]' );

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

        # FIXME these are stored in Investigation, so I'm not too sure
        # how we can reliably retrieve them here.

#        'termSources' => [
#            sub { return ( [ 'Term Source Name',       map { $_->get_name()    } @_ ] ) },
#            sub { return ( [ 'Term Source Version',    map { $_->get_version() } @_ ] ) },
#            sub { return ( [ 'Term Source File',       map { $_->get_uri()     } @_ ] ) },
#        ],
        
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
    ATTR:
    while ( my ( $field, $subs ) = each %multi ) {
        my $getter = "get_$field";
        my @attrs = $array->$getter;
        next ATTR if ( scalar @attrs == 1 && ! defined $attrs[0] );
        foreach my $sub ( @$subs ) {
            foreach my $lineref ( $sub->( @attrs ) ) {
                $self->_write_line( @{ $lineref } );
            }
        }
    }

    # Attach all comments to the ArrayDesign.
    foreach my $comment ( $array->get_comments() ) {
        my $field = sprintf("Comment[%s]", $comment->get_name());
        $self->_write_line( $field, $comment->get_value() );
    }

    return;
}

sub _get_reporter_tag_lists {

    my ( $self ) = @_;

    my $array = $self->get_magetab_object();

    my @reporters = grep { UNIVERSAL::isa( $_, 'Bio::MAGETAB::Reporter' ) }
                       $array->get_designElements();

    my (%db_name, %group_name);
    foreach my $rep ( @reporters ) {
        foreach my $db_entry ( $rep->get_databaseEntries() ) {
            my $ts = $db_entry->get_termSource();
            $db_name{ $ts->get_name() }++ if $ts;
        }
        foreach my $group ( $rep->get_groups() ) {
            $group_name{ $group->get_category() }++;
        }
    }
    my @dbs    = sort keys %db_name;
    my @groups = sort keys %group_name;

    return \@dbs, \@groups;
}

sub _get_composite_tag_lists {

    my ( $self ) = @_;

    my $array = $self->get_magetab_object();

    my @composites = grep { UNIVERSAL::isa( $_, 'Bio::MAGETAB::CompositeElement' ) }
                       $array->get_designElements();

    my %db_name;
    foreach my $elem ( @composites ) {
        foreach my $db_entry ( $elem->get_databaseEntries() ) {
            my $ts = $db_entry->get_termSource();
            $db_name{ $ts->get_name() }++ if $ts;
        }
    }
    my @dbs = sort keys %db_name;

    return \@dbs;
}

sub _generate_main_header_line {

    my ( $self, $reporter_dbs, $groups, $composite_dbs ) = @_;

    my @header = (
        'Block Column',
        'Block Row',
        'Column',
        'Row',
        'Reporter Name',
        'Reporter Sequence',
        ( map { "Reporter Database Entry [$_]" } @$reporter_dbs    ),
        ( map { "Reporter Group [$_]" }          @$groups ),
    );
    if ( scalar @$groups ) {
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

    # CompositeElement.
    unless ( $self->_must_generate_mapping() ) {
        push @header,
            'Composite Element Name',
            ( map { "Composite Element Database Entry [$_]" } @$composite_dbs ),
            'Composite Element Comment';
    }

    return \@header;
}

sub _get_feature_coords {

    my ( $self, $feature ) = @_;

    my @coords = map { $feature->$_ }
        qw( get_blockCol get_blockRow get_col get_row );

    return @coords;
}

sub _get_element_dbentries {

    my ( $self, $element, $dbs ) = @_;

    my @accessions;
    my %accession = map {
        my $ts = $_->get_termSource();
        ( $ts ? $ts->get_name() : q{} ) => $_->get_accession();
    } $element->get_databaseEntries();
    foreach my $db ( @$dbs ) {
        my $acc = $accession{ $db };
        push @accessions, ( defined $acc ? $acc : q{} );
    }

    return @accessions;
}

sub _get_reporter_groups {

    my ( $self, $reporter, $groups ) = @_;

    my @groups;
    my %group = map {
        $_->get_category() => $_->get_value()
    } $reporter->get_groups();
    foreach my $name ( @$groups ) {
        my $gr = $group{ $name };
        push @groups, ( defined $gr ? $gr : q{} );
    }

    return @groups;
}

sub _get_reporter_group_source {

    my ( $self, $reporter, $groups ) = @_;

    my @sources;

    # Group Term Source and Accession, where needed.
    if ( scalar @$groups ) {
        my @rep_groups = $reporter->get_groups();
        if ( scalar @rep_groups > 1 ) {
            carp(qq{Warning: Multiple Reporter Group Term Sources/Accessions not supported. }
               . qq{ADF output only contains these values for "}
               . $rep_groups[0]->get_category() . qq{"\n})
        }
        push @sources, $self->_get_type_termsource_name( $rep_groups[0] );
        my $acc = $rep_groups[0]->get_accession();
        push @sources, ( defined $acc ? $acc : q{} );
    }

    return @sources;
}

sub _get_reporter_control_type {

    my ( $self, $reporter ) = @_;

    my @typeinfo;
    if ( my $ctype = $reporter->get_controlType() ) {
        push @typeinfo, $ctype->get_value();
        push @typeinfo, $self->_get_type_termsource_name( $ctype );
        my $acc = $ctype->get_accession();
        push @typeinfo, ( defined $acc ? $acc : q{} );
    }
    else {
        push @typeinfo, (q{}) x 3;
    }

    return @typeinfo;
}

sub _generate_reporter_data {

    my ( $self, $reporter, $dbs, $groups ) = @_;

    my @data;
    push @data, $reporter->get_name(), $reporter->get_sequence();

    # Get the database entries, in order.
    push @data, $self->_get_element_dbentries( $reporter, $dbs );

    # Get the group names, in order.
    push @data, $self->_get_reporter_groups(       $reporter, $groups );
    push @data, $self->_get_reporter_group_source( $reporter, $groups );

    # Control Type.
    push @data, $self->_get_reporter_control_type( $reporter );

    return @data;
}

sub _generate_composite_data {

    my ( $self, $composite, $dbs ) = @_;

    my @data = $composite->get_name();

    # Get the database entries, in order.
    push @data, $self->_get_element_dbentries( $composite, $dbs );

    if ( my $comm = $composite->get_comment() ) {
        push @data, $comm->get_value();
    }
    else {
        push @data, q{};
    }

    return @data;
}

sub _must_generate_mapping {

    my ( $self ) = @_;

    unless ( $self->has_cached_mapping_flag() ) {

        # Check all reporters; if any map to more than one CE, we need
        # a mapping section. The result is cached so we only check
        # this once.
        my $array = $self->get_magetab_object();
        my @reporters = grep { UNIVERSAL::isa( $_, 'Bio::MAGETAB::Reporter' ) }
            $array->get_designElements();

        REPORTER:
        foreach my $rep ( @reporters ) {
            if ( scalar @{ [ $rep->get_compositeElements() ] } > 1 ) {
                $self->set_cached_mapping_flag(1);
                last REPORTER;
            }
        }

        $self->set_cached_mapping_flag(0)
            unless $self->has_cached_mapping_flag();
    }

    return $self->get_cached_mapping_flag();
}

sub _write_main {

    my ( $self ) = @_;

    my $array = $self->get_magetab_object();

    # Figure out which databases are represented.
    my ( $reporter_dbs, $groups ) = $self->_get_reporter_tag_lists();
    my $composite_dbs             = $self->_get_composite_tag_lists();

    # FIXME beware memory issues here; consider creating an iterator
    # to access some of these objects? This would probably need to be
    # in the actual Bio::MAGETAB model, possibly with a file- or
    # db-based backend.
    my @features = grep { UNIVERSAL::isa( $_, 'Bio::MAGETAB::Feature' ) }
                       $array->get_designElements();
    
    # Print out the column headings.
    my $header = $self->_generate_main_header_line( $reporter_dbs,
                                                    $groups,
                                                    $composite_dbs );
    $self->set_num_columns( scalar @$header );
    $self->_write_line( '[main]' );
    $self->_write_line( @$header );

    # Loop through all the features, writing out the info.
    foreach my $feature ( @features ) {

        # Sort out the basics;
        my @line = $self->_get_feature_coords( $feature );

        # Simple reporter info.
        my $reporter = $feature->get_reporter();
        push @line, $self->_generate_reporter_data( $reporter, $reporter_dbs, $groups );

        unless ( $self->_must_generate_mapping() ) {

            # There will be only one CompositeElement in such cases.
            my $composite = $reporter->get_compositeElements();
            push @line, $self->_generate_composite_data( $composite, $composite_dbs );
        }

        # Write out the line.
        $self->_write_line( @line );
    }

    # These may be needed for the mapping section.
    return $composite_dbs;
}

sub _write_mapping {

    my ( $self, $dbs ) = @_;

    my $array = $self->get_magetab_object();
    my @header = (
        'Composite Element Name',
        'Map2Reporters',
        ( map { "Composite Element Database Entry [$_]" } @$dbs ),
        'Composite Element Comment',
    );

    # Print out the column headings.
    $self->set_num_columns( scalar @header );
    $self->_write_line( '[mapping]' );
    $self->_write_line( @header );
    
    my @compelems = grep { UNIVERSAL::isa( $_, 'Bio::MAGETAB::CompositeElement' ) }
                       $array->get_designElements();

    foreach my $element ( @compelems ) {
        my @line = (
            $element->get_name(),
            join(';', map { $_->get_name() } $element->get_reporters() ),
            $self->_get_element_dbentries( $element, $dbs ),
            $element->get_comments(),
        );
    }

    return;
}

sub write {

    my ( $self ) = @_;

    # First, the header section.
    $self->_write_header();

    $self->_write_line( q{} );    # spacer line

    # The main body of the ADF.
    my $comp_dbs = $self->_write_main();

    $self->_write_line( q{} );    # spacer line

    # Where necessary, the ADF mapping section.
    if ( $self->_must_generate_mapping() ) {
        $self->_write_mapping( $comp_dbs );
    }

    return;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=head1 NAME

Bio::MAGETAB::Util::Writer::ADF - Export of MAGE-TAB ArrayDesign
objects.

=head1 SYNOPSIS

 use Bio::MAGETAB::Util::Writer::ADF;
 my $writer = Bio::MAGETAB::Util::Writer::ADF->new({
    magetab_object => $array_design,
    filename       => $adf_fh,
 });
 
 $writer->write();

=head1 DESCRIPTION

Export of ArrayDesigns to ADF files.

=head1 ATTRIBUTES

See L<Bio::MAGETAB::Util::Writer::Tabfile> for superclass attributes.

=over 2

=item magetab_object

The Bio::MAGETAB::ArrayDesign to export. This is a required
attribute.

=item cached_mapping_flag

A flag, for internal use only, that helps determine whether a
"[mapping]" section needs to be generated in the output ADF.

=back

=head1 METHODS

=over 2

=item write

Exports the ArrayDesign to ADF.

=back

=head1 SEE ALSO

L<Bio::MAGETAB::Writer>, L<Bio::MAGETAB::Writer::Tabfile>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
