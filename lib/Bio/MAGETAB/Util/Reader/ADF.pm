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

package Bio::MAGETAB::Util::Reader::ADF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

BEGIN { extends 'Bio::MAGETAB::Util::Reader::TagValueFile' };

has 'magetab_object'     => ( is         => 'rw',
                              isa        => 'Bio::MAGETAB::ArrayDesign',
                              required   => 0 );

# FIXME the following should be in some standard location, maybe the superclass?
# Define some standard regexps:
my $RE_EMPTY_STRING             = qr{\A \s* \z}xms;
my $RE_COMMENTED_STRING         = qr{\A [\"\s]* \#}xms;
my $RE_SURROUNDED_BY_WHITESPACE = qr{\A [\"\s]* (.*?) [\"\s]* \z}xms;

sub BUILD {

    my ( $self, $params ) = @_;

    # FIXME not sure if this will work. When are required attributes checked by Moose?
    if ( my $obj = $params->{'magetab_object'} ) {
        $self->set_uri( $obj->get_uri() );
    }

    my $dispatch = {
        qr/Array *Design *Name/i
            => sub{ $self->_add_singleton_datum('array_design', 'name', @_) },
        qr/Version/i
            => sub{ $self->_add_singleton_datum('array_design', 'version', @_) },
        qr/Provider/i
            => sub{ $self->_add_singleton_datum('array_design', 'provider', @_) },
        qr/Printing *Protocol/i
            => sub{ $self->_add_singleton_datum('array_design', 'printingProtocol', @_) },

        qr/Technology *Type/i
            => sub{ $self->_add_grouped_data('technology', 'type',       @_) },
        qr/Technology *(?:Type)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('technology', 'termSource', @_) },
        qr/Technology *(?:Type)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('technology', 'accession',  @_) },

        qr/Surface *Type/i
            => sub{ $self->_add_grouped_data('surface', 'type',       @_) },
        qr/Surface *(?:Type)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('surface', 'termSource', @_) },
        qr/Surface *(?:Type)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('surface', 'accession',  @_) },

        qr/Substrate *Type/i
            => sub{ $self->_add_grouped_data('substrate', 'type',       @_) },
        qr/Substrate *(?:Type)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('substrate', 'termSource', @_) },
        qr/Substrate *(?:Type)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('substrate', 'accession',  @_) },

        qr/Sequence *Polymer *Type/i
            => sub{ $self->_add_grouped_data('polymer', 'type',       @_) },
        qr/Sequence *Polymer *(?:Type)? *Term *Source *REF/i
            => sub{ $self->_add_grouped_data('polymer', 'termSource', @_) },
        qr/Sequence *Polymer *(?:Type)? *Term *Accession *Numbers?/i
            => sub{ $self->_add_grouped_data('polymer', 'accession',  @_) },

        qr/Term *Source *Names?/i
            => sub{ $self->_add_grouped_data('termsource', 'name',     @_) },
        qr/Term *Source *Files?/i
            => sub{ $self->_add_grouped_data('termsource', 'uri',      @_) },
        qr/Term *Source *Versions?/i
            => sub{ $self->_add_grouped_data('termsource', 'version',  @_) },        
    };

    $self->set_dispatch_table( $dispatch );

    return;
}

sub parse {

    my ( $self ) = @_;

    $self->parse_header();
    $self->parse_body();

    return $self->get_magetab_object();
}

sub parse_body {

    my ( $self ) = @_;

    # FIXME

    croak;
}

sub parse_header {

    my ( $self ) = @_;

    # Parse the initial tag-value ADF header into memory here.
    my $array_of_rows = $self->_read_header_as_arrayref();

    # Check tags for duplicates, make sure that tags are recognized.
    my $adf_hash = $self->_validate_arrayref_tags( $array_of_rows );

    # Populate the ADF object's internal data text_store attribute.
    while ( my ( $tag, $values ) = each %$adf_hash ) {
	$self->_dispatch( $tag, @$values );
    }

    # Actually generate the Bio::MAGETAB objects.
    my ( $array_design, $magetab ) = $self->_generate_magetab();

    return ( $array_design, $magetab );
}

sub _generate_magetab {

    my ( $self ) = @_;

    my $magetab      = $self->get_builder()->get_magetab();
    my $array_design = $self->_create_array_design();

    return ( $array_design, $magetab );
}

sub _generate_array_design {

    my ( $self ) = @_;

    my $technology_types = $self->_create_controlled_terms(
        'technology',      'TechnologyType',   # FIXME hard-coded
    );
    my $surface_types    = $self->_create_controlled_terms(
        'surface',         'SurfaceType',      # FIXME hard-coded
    );
    my $substrate_types  = $self->_create_controlled_terms(
        'substrate',       'SubstrateType',    # FIXME hard-coded
    );
    my $polymer_types    = $self->_create_controlled_terms(
        'polymer',         'PolymerType',      # FIXME hard-coded
    );

    my $data = $self->get_text_store()->{'array_design'};
    
    # Find or create the target ArrayDesign object.  N.B. we can only
    # use the first of each set of controlled terms here, since these
    # are 0..1 both in the specification and the model.
    my $array_design;
    if ( $array_design = $self->get_magetab_object() ) {
        $array_design->set_name               ( $data->{'name'}             );
        $array_design->set_version            ( $data->{'version'}          );
        $array_design->set_provider           ( $data->{'provider'}         );
        $array_design->set_printingProtocol   ( $data->{'printingProtocol'} );
        $array_design->set_technologyType     ( $technology_types->[0]      );
        $array_design->set_surfaceType        ( $surface_types->[0]         );
        $array_design->set_substrateType      ( $substrate_types->[0]       );
        $array_design->set_sequencePolymerType( $polymer_types->[0]         );
    }
    else {
        $array_design = $self->get_builder()->find_or_create_array_design({
            %data,
            technologyType      => $technology_types->[0],
            surfaceType         => $surface_types->[0],
            substrateType       => $substrate_types->[0],
            sequencePolymerType => $polymer_types->[0],
        });
        $self->set_magetab_object( $array_design );
    }

    my $comments = $self->_create_comments();
    $array_design->set_comments( $comments );

    return $array_design;    
}

sub _read_header_as_arrayref {

    my ( $self ) = @_;
    
    # This has to be set for Text::CSV_XS.
    local $/ = $self->_calculate_eol_char();

    my $adf_fh     = $self->_get_filehandle();
    my $csv_parser = $self->_get_csv_parser();

    seek( $adf_fh, 0, 0 ) or croak("Error seeking within ADF filehandle: $!\n");

    FILE_LINE:
    while ( $larry = $csv_parser->getline($adf_fh) ) {
    
        # Skip empty lines.
        my $line = join( q{}, @$larry );
        next FILE_LINE if ( $line =~ $RE_EMPTY_STRING );

        # Allow hash comments.
        next FILE_LINE if ( $line =~ $RE_COMMENTED_STRING );

	# Strip surrounding whitespace from each element.
	foreach my $element ( @$larry ) {
	    $element =~ s/$RE_SURROUNDED_BY_WHITESPACE/$1/xms;
	}

        my ( $tag, @values ) = @$larry;

        next FILE_LINE if ( $tag =~ /\A \[ [ ]* header [ ]* \] \z/ixms );
        last FILE_LINE if ( $tag =~ /\A \[ [ ]* (?:main|mapping) [ ]* \] \z/ixms );

        # Strip off empty trailing values.
	my $end_value;
	until ( defined($end_value) && $end_value !~ /\A \s* \z/xms ) {
	    $end_value = pop(@$larry);
	}
	push @$larry, $end_value;

	# Reset empty strings to undefs.
	foreach my $value ( @$larry ) {
	    undef($value) if ( defined($value) && $value eq q{} );
	}

	push @rows, $larry;
    }

    # Check we've parsed to the end of the file.
    my ( $error, $mess ) = $csv_parser->error_diag();
    unless ( $error == 2012 ) {    # 2012 is the Text::CSV_XS EOF code.
	croak(
	    sprintf(
		"Error in tab-delimited format: %s. Bad input was:\n\n%s\n",
		$mess,
		$csv_parser->error_input(),
	    ),
	);
    }

    return \@rows;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
