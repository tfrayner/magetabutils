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

package Bio::MAGETAB::Util::Reader::SDRF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;
use List::Util qw(first);
use English qw( -no_match_vars );
use Parse::RecDescent;
#use Readonly;
#use File::Basename;

use Bio::MAGETAB::Util::Reader::Builder;

BEGIN { extends 'Bio::MAGETAB::Util::Reader::Tabfile' };

has 'builder'             => ( is         => 'ro',
                               isa        => 'Bio::MAGETAB::Util::Reader::Builder',
                               default    => sub { Bio::MAGETAB::Util::Reader::Builder->new() },
                               required   => 1 );

# Define some standard regexps:
my $RE_EMPTY_STRING             = qr{\A \s* \z}xms;
my $RE_COMMENTED_STRING         = qr{\A [\"\s]* \#}xms;
my $RE_SURROUNDED_BY_WHITESPACE = qr{\A [\"\s]* (.*?) [\"\s]* \z}xms;
my $BLANK = qr/\A [ ]* \z/xms;

# The Parse::RecDescent grammar is stored in the __DATA__ section, below.
my $GRAMMAR = join("\n", <DATA> );

#my %skip_datafiles    : ATTR( :name<skip_datafiles>,      :default<undef> );

sub parse {

    my ( $self ) = @_;

    # This has to be set for Text::CSV_XS.
    local $/ = $self->_calculate_eol_char();

    my $row_parser = $self->parse_header();
    my $sdrf_fh    = $self->_get_filehandle();
    my $csv_parser = $self->_get_csv_parser();

    my $larry;

    # Run through the rest of the file with the row-level parser.
    FILE_LINE:
    while ( $larry = $csv_parser->getline($sdrf_fh) ) {
    
        # Skip empty lines.
        my $line = join( q{}, @$larry );
        next FILE_LINE if ( $line =~ $RE_EMPTY_STRING );

        # Allow hash comments.
        next FILE_LINE if ( $line =~ $RE_COMMENTED_STRING );

	# Strip surrounding whitespace from each element.
	foreach my $element ( @$larry ) {
	    $element =~ s/$RE_SURROUNDED_BY_WHITESPACE/$1/xms;
	}

	# FIXME some error handling wouldn't go amiss here.
	$row_parser->(@$larry);
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

#    $self->simplify_single_channels();

#    $self->propagate_fvs_to_datafiles();

    return; #$self->get_datafiles();
}

sub parse_header {

    # Generates a row-level parser function based on the first line in the SDRF.

    # $::sdrf is a qualified $self, used below in the Parse::RecDescent grammar.
    ( $::sdrf ) = @_;

    # Globals to record the previous material and event (bioassay) in
    # the chain.
    our ($previous_material,
	 $previous_event,
	 $previous_data,
	 $array_accession,
	 $channel);

    # FIXME add support for REF:namespaces (currently accepted, but
    # discarded for termsource).

    # Check linebreaks; get first line as $header_string and generate
    # row-level parser.
    my $csv_parser = $::sdrf->_get_csv_parser();
    my $sdrf_fh    = $::sdrf->_get_filehandle();

    # Get the header line - the first non-empty, non-comment line in the file.
    my ( $header_string, $harry );
    HEADERLINE:
    while ( $harry = $csv_parser->getline($sdrf_fh) ) {

	$header_string = join( qq{\x{0}}, @$harry );

	# Skip empty and commented lines.
        if (   $header_string
	    && $header_string !~ $RE_EMPTY_STRING
	    && $header_string !~ $RE_COMMENTED_STRING ) {

	    # We've found the header line. Add a starting skip
	    # character for the benefit of the parser.
	    $header_string = qq{\x{0}} . $header_string;
	    last HEADERLINE;
	}
    }

    # Check we have no CSV parse errors.
    my ( $error, $mess ) = $csv_parser->error_diag();
    unless ( $harry || $error == 2012 ) {    # 2012 is the Text::CSV_XS EOF code.
	croak(
	    sprintf(
		"Error in tab-delimited format: %s. Bad input was:\n\n%s\n",
		$mess,
		$csv_parser->error_input(),
	    ),
	);
    }

    # N.B. MAGE-TAB 1.1 SDRFs can actually be empty, so an empty
    # $header_string is valid at this point.

    # FIXME This next line is an egregious hack; it reopens an
    # (*undocumented*) filehandle in the Parse::RecDescent module to a
    # local variable so we can capture STDERR. I tried doing this the
    # correct way (open(local *STDERR, '>', \$parse_error)) but
    # couldn't get it to work properly. We'll want to revisit this at
    # some point.
    open( *Parse::RecDescent::ERROR, '>', \(my $parse_error) )
	or croak("Error: unable to redirect STDERR for MAGE-TAB header parsing.");

    # Set the token separator character.
    $Parse::RecDescent::skip = ' *\x{0} *';

    # FIXME most of these are removable once development is advanced.
    $::RD_ERRORS++;       # unless undefined, report fatal errors
    $::RD_WARN++;         # unless undefined, also report non-fatal problems
    $::RD_HINT++;         # if defined, also suggestion remedies

    # Generate the grammar parser first.
    my $parser = Parse::RecDescent->new($GRAMMAR) or die("Bad grammar!");

    # The parser should return a function which can process each SDRF
    # row as an array (row-level parser).
    my $row_parser = $parser->header($header_string);

    # Typically the grammar will generate some error messages before
    # we get here. N.B. $! doesn't really give a useful error here so
    # we don't use it.
    unless (defined $row_parser) {
	die(
	    qq{\nERROR parsing header line:\n} . $parse_error
	);
    }

    return $row_parser;
}

sub create_source {

    my ( $self, $name ) = @_;

    return if ( $name =~ $BLANK );

    my $source = $self->get_builder()->find_or_create_source({
        name  => $name,
    });

    return $source;
}

sub _link_to_previous {

    my ( $self, $obj, $previous, $protocolapps ) = @_;

    if ( $previous ) {
        my $edge = $self->get_builder()->find_or_create_edge({
            inputNode  => $previous,
            outputNode => $obj,
        });

        if ( $protocolapps && scalar @{ $protocolapps } ) {
            $edge->set_protocolApplications( $protocolapps );
        }
    }

    return;
}

sub create_sample {

    my ( $self, $name, $previous, $protocolapps ) = @_;

    return if ( $name =~ $BLANK );

    my $sample = $self->get_builder()->find_or_create_sample({
        name => $name,
    });

    $self->_link_to_previous( $sample, $previous, $protocolapps );

    return $sample;
}

sub create_extract {

    my ( $self, $name, $previous, $protocolapps ) = @_;

    return if ( $name =~ $BLANK );

    my $extract = $self->get_builder()->find_or_create_extract({
        name => $name,
    });

    $self->_link_to_previous( $extract, $previous, $protocolapps );

    return $extract;
}

sub create_labeled_extract {

    my ( $self, $name, $previous, $protocolapps ) = @_;

    return if ( $name =~ $BLANK );

    # Create a dummy label that isn't tracked by the Bio::MAGETAB
    # container or the Builder object. This will be replaced later
    # when the Label column is parsed; this dummy just acts as a
    # fail-safe placeholder for a required attribute.
    my $dummy_label = Bio::MAGETAB::Label->new(
        category => 'LabelCompound',
        value    => 'unknown',
    );
    $self->get_builder()->get_magetab()->delete_objects( $dummy_label );

    my $labeled_extract = $self->get_builder()->find_or_create_labeled_extract({
        name  => $name,
        label => $dummy_label,
    });

    $self->_link_to_previous( $labeled_extract, $previous, $protocolapps );

    return $labeled_extract;
}

sub create_label {

    my ( $self, $dyename, $termsource, $accession, $le ) = @_;

    return if ( $dyename =~ $BLANK );

    my $ts_obj;
    if ( $termsource ) {
        $ts_obj = $self->get_builder()->get_term_source( $termsource );
    }

    my $label = $self->get_builder()->find_or_create_controlled_term({
        'category'   => 'LabelCompound',
        'value'      => $dyename,
        'accession'  => $accession,
        'termSource' => $termsource,
    });

    $le->set_label( $label ) if $le;

    return $label;
}

sub create_protocolapplication {

    my ( $self, $name, $namespace, $termsource, $accession ) = @_;

    # FIXME do something more with Term Source, accession? MAGE-TAB
    # model probably needs fixing here.

    return if ( $name =~ $BLANK );

    my ( $protocol, $ts_obj );

    # If we have a valid namespace or termsource, let it through.
    if ( $termsource ) {

        $ts_obj   = $self->get_builder()->get_term_source( $termsource );
        $protocol = $self->get_builder()->find_or_create_protocol({
            name      => $name,
        });

        $protocol->set_namespace( $namespace ) if defined $namespace;

#        $protocol->set_term_source( FIXME not what I actually want ) if $ts_obj;
    }
    elsif ( $namespace ) {

        # FIXME what about authority here?
        $protocol = $self->get_builder()->find_or_create_protocol({
            name      => $name,
            namespace => $namespace,
        });
    }
    else {

        # Simple case; this call will die if $name is not valid.
        $protocol = $self->get_builder()->get_protocol( $name );
    }

    # FIXME we really need more at the point of instantiation; grammar may need changing.
    my $protocol_app = $self->get_builder()->create_protocol_application({
        protocol => $protocol,
    });

    return $protocol_app;
}

sub create_parametervalue {

    my ( $self, $paramname, $value, $protocolapp ) = @_;

    return if ( $value =~ $BLANK );

    my $protocol = $protocolapp->get_protocol();
    my $protname = $protocol->get_name() || q{};

    my $parameter = $self->get_builder()->get_parameter( $paramname, $protocol );
    my $measurement = $self->get_builder()->create_measurement({
        value => $value,
    });

    my $parameterval = $self->get_builder()->create_parameter_value({
        parameter   => $parameter,
        measurement => $measurement,
#        FIXME fun stuff here, also consider altering grammar for unit.
    });

    $self->add_parameterval_to_protocolapp(
	$parameterval,
	$protocolapp,
    ) if $protocolapp;

    return $parameterval;
}

sub add_parameterval_to_protocolapp : PRIVATE {

    my ( $self, $parameterval, $protocolapp ) = @_;

    my $found;
    if ( my $preexisting_values = $protocolapp->get_parameterValues() ) {

	my $parameter = $parameterval->get_parameter();
	$found = first {
	    $_->get_parameter() eq $parameter
	}   @$preexisting_values;
    }
    unless ( $found ) {
        my $values = $protocolapp->get_parameterValues();
        push @{ $values }, $parameterval;
        $protocolapp->set_parameterValues($values);
    }

    return;
}

# FIXME OE as adjunct to parameter not supported by MAGE-TAB model.
# At the moment (v1.1 DRAFT) it seems that OE is not required, but
# we'll keep this here in case that ever changes.
sub add_value_to_parameter {

    my ( $self, $parameter, $termsource, $accession ) = @_;

    return if ( $termsource =~ $BLANK || ! $parameter );

    my $ts_obj = $self->get_builder()->get_term_source( $termsource );

    # FIXME hard-coded category because MAGE-TAB has nowhere to
    # specify this at the moment.
    my $term = $self->get_builder()->find_or_create_controlled_term({
        category   => 'ParameterValue',
        value      => $parameter->get_value(),
        accession  => $accession,
        termSource => $ts_obj,
    });

    # Delete the measurement (FIXME the grammar action needs changing
    # here if OE is ever supported).
    $parameter->clear_value();

    # FIXME this call not yet implemented and will fail.
    $parameter->set_term( $term );

    return;
}

sub create_unit {

    my ( $self, $type, $name, $termsource, $accession ) = @_;

    return if ( $name =~ $BLANK );

    my $ts_obj;
    if ( $termsource ) {
        $ts_obj = $self->get_builder()->get_term_source( $termsource );
    }

    my $unit = $self->get_builder()->find_or_create_controlled_term({
        category   => $type,
        value      => $name,
        accession  => $accession,
        termSource => $ts_obj,
    });

    return $unit;
}

sub add_unit_to_thing {

    my ( $self, $unit, $thing ) = @_;

    return unless ( $unit && $thing );

    if ( $thing->can('set_unit') ) {
	$thing->set_unit( $unit );
    }
    else {
	croak("Error: Cannot process argument: $thing (" . blessed($thing) .")");
    }

    return;
}

sub create_technology_type {

    my ( $self, $assay, $value, $termsource, $accession ) = @_;

    return if ( $value =~ $BLANK );

    my $ts_obj;
    if ( $termsource ) {
        $ts_obj = $self->get_builder()->get_term_source( $termsource );
    }

    my $type = $self->get_builder()->find_or_create_controlled_term({
        category   => 'TechnologyType',    #FIXME hard-coded.
        value      => $value,
        accession  => $accession,
        termSource => $ts_obj,
    });

    if ( $assay ) {
        $assay->set_technologyType( $type );
    }

    return $type;
}

sub create_hybridization {

    my ( $self, $name, $previous, $protocolapps, $channel ) = @_;

    return if ( $name =~ $BLANK );

    my $default_type = $self->get_builder()->find_or_create_controlled_term({
        category   => 'TechnologyType',    #FIXME hard-coded.
        value      => 'hybridization',     #FIXME hard-coded.
    });

    my $hybridization = $self->get_builder()->find_or_create_assay({
        name           => $name,
        technologyType => $default_type,
    });

    $self->_link_to_previous( $hybridization, $previous, $protocolapps );

    return $hybridization;
}

sub create_assay {

    my ( $self, $name, $previous, $protocolapps, $channel ) = @_;

    return if ( $name =~ $BLANK );

    my $dummy_type = $self->get_builder()->find_or_create_controlled_term({
        category   => 'TechnologyType',    #FIXME hard-coded.
        value      => 'unknown',           #FIXME hard-coded.
    });

    # Pre-delete the dummy term.
    $self->get_builder()->get_magetab()->delete_objects( $dummy_type );

    my $assay = $self->get_builder()->find_or_create_assay({
        name           => $name,
        technologyType => $dummy_type,
    });

    $self->_link_to_previous( $assay, $previous, $protocolapps );

    return $assay;
}

sub create_array {

    my ( $self, $name, $namespace, $termsource, $accession, $assay ) = @_;

    # $name is the term in the Array Design REF column;
    # $accession is the optional contents of the Term Accession
    # Number column.

    return if ( $name =~ $BLANK );

    my $ts_obj;
    if ( $termsource ) {
        $ts_obj = $self->get_builder()->get_term_source( $termsource );
    }

    my $array_design = $self->get_builder()->find_or_create_array({
        name       => $name,
        accession  => $accession,
        termSource => $ts_obj,
    });

    if ( $assay ) {
        $assay->set_arrayDesign( $array_design );
    }

    return $array_design;
}

sub create_scan {

    my ( $self, $name, $previous, $protocolapps ) = @_;

    return if ( $name =~ $BLANK );

    my $scan = $self->get_builder()->find_or_create_data_acquisition({
        name => $name,
    });

    $self->_link_to_previous( $scan, $previous, $protocolapps );

    return $scan;
}

sub create_normalization {

    my ( $self, $name, $previous, $protocolapps ) = @_;

    return if ( $name =~ $BLANK );

    my $normalization = $self->get_builder()->find_or_create_normalization({
        name => $name,
    });

    $self->_link_to_previous( $normalization, $previous, $protocolapps );

    return $normalization;
}

sub create_data_file {

    my ( $self, $uri, $previous, $protocolapps ) = @_;

    return if ( $uri =~ $BLANK );

    # FIXME we need a data format, but MAGE-TAB has nowhere to specify
    # it. This is a very basic start on a way to automatically derive
    # formats from what we know. Consider putting this in a separate
    # method which can then be subclassed. Possible additions include
    # parsing the CEL, CHP headers to get the exact format version.
    my %known = (
        'cel'    => 'CEL',
        'chp'    => 'CHP',
        'gpr'    => 'GPR',
	'tif'    => 'TIFF',
	'tiff'   => 'TIFF',
	'jpg'    => 'JPEG',
	'jpeg'   => 'JPEG',
	'png'    => 'PNG',
	'gif'    => 'GIF',
    );

    my $format_str = 'unknown';
    if ( my ( $ext ) = ( $uri =~ m/\. (\w{3,4}) \z/xms ) ) {
	if ( my $term = $known{lc($ext)} ) {
	    $format_str = $term;
	}
    }

    my $format = $self->get_builder()->find_or_create_controlled_term({
        category => 'DataFormat',    # FIXME hard-coded.
        value    => $format_str,
    });

    # FIXME we may also need a dataType attribute (e.g. 'image',
    # 'raw', 'derived').
    my $data_file = $self->get_builder()->find_or_create_data_file({
        uri        => $uri,
        dataFormat => $format,
    });

    $self->_link_to_previous( $data_file, $previous, $protocolapps );

    return $data_file;
}

sub create_data_matrix {

    my ( $self, $uri, $previous, $protocolapps ) = @_;

    return if ( $uri =~ $BLANK );

    # FIXME there's a lot more here to get, probably by actually
    # parsing the data matrix file.
    my $data_matrix = $self->get_builder()->find_or_create_data_matrix({
        uri => $uri,
    });

    $self->_link_to_previous( $data_file, $previous, $protocolapps );

    return $data_matrix;
}

sub create_factorvalue_value {

    my ( $self, $factorname, $altcategory, $value, $termsource, $accession ) = @_;

    return if ( $value =~ $BLANK );

    my ($factorvalue, $exp_factor)
	= $self->create_generic_factorvalue( $factorname, $value, $altcategory );

    my $category;
    if ( $altcategory ) {

	# If we're given a category in parentheses, use it.
	$category = $altcategory;
    }
    else {

	# Otherwise, derive the category from the EF term:
	my $ef_oe = $exp_factor->getCategory()
	    or croak("Error: Experimental Factor $factorname has no type.");

	my @ef_catparts = split /_/, $ef_oe->getValue();

	$category = join(q{}, map{ ucfirst($_) } @ef_catparts);
    }

    my $oe = $self->create_ontologyentry( $category, $value, $termsource, $accession );

    $factorvalue->setValue( $oe );

    $self->add_factorvalue_to_factor( $factorvalue, $exp_factor );

    return $factorvalue;
}

sub create_factorvalue_measurement {

    my ( $self, $factorname, $altcategory, $value, $unit ) = @_;

    return if ( $value =~ $BLANK );

    # Note: $altcategory is ignored for measurement.

    my $unitname;
    if ( $unit ) {
        $unitname = $self->get_unitname_for_unit( $unit );
    }

    # Here we're retasking the altcategory slot for unitname; this is
    # a bit naughty. FIXME.
    my ($factorvalue, $exp_factor) = $self->create_generic_factorvalue(
        $factorname,
        $value,
        $unitname,
    );

    my $measurement = Bio::MAGE::Measurement::Measurement->new(
	value => $value,
        unit  => $unit,
    );

    $factorvalue->setMeasurement( $measurement );

    # This has to be done *after* adding the unit to the term. It's
    # now handled in the relevant grammar action.
#    $self->add_factorvalue_to_factor( $factorvalue, $exp_factor );

    return wantarray ? ($factorvalue, $exp_factor) : $factorvalue;
}

sub create_generic_factorvalue : PRIVATE {

    my ( $self, $factorname, $value, $altcategory ) = @_;

    my $args;
    if ( $self->get_in_relaxed_mode() ) {
	$args = {name => $factorname, type => $factorname};
    }

    my $exp_factor = $self->factor_bag(	$factorname, $args )
	or croak(qq{Error: Experimental Factor Name not found: "$factorname"\n}); 

    my $identifier_template = $self->generate_id_template(
	$altcategory ? "$factorname.$altcategory.$value" : "$factorname.$value"
    );

    my $name = defined $altcategory ? "$value $altcategory" : $value;
    my $factorvalue = $self->factorvalue_bag(
	"$factorname.$name",
	{
	    identifier_template => $identifier_template,
	    name                => $name,
	},
    );

    return wantarray
	   ? ( $factorvalue, $exp_factor )
	   : $factorvalue;
}

sub create_description {

    my ( $self, $text, $describable ) = @_;

    return if ( $text =~ $BLANK );

    my $description = Bio::MAGE::Description::Description->new(
	text => $text,
    );

    $self->add_description_to_describable( $description, $describable)
	if $describable;

    return $description;
}

sub create_nvt {

    my ( $self, $name, $value, $type, $extendable ) = @_;

    return if ( $value =~ $BLANK );

    my $nvt = Bio::MAGE::NameValueType->new(
	name  => $name,
	value => $value,
	type  => $type,
    );

    $self->add_nvt_to_extendable( $nvt, $extendable )
	if $extendable;

    return $nvt;
}

sub add_char_to_material {

    my ( $self, $char, $material ) = @_;

    return unless ( $material && $char );

    my $found;
    if ( my $preexisting_chars = $material->getCharacteristics() ) {

	my $new_category = $char->getCategory();
	my $new_value    = $char->getValue();
	$found = first {
	       $_->getCategory() eq $new_category
	    && $_->getValue()    eq $new_value;
	}   @$preexisting_chars;
    }
    $material->addCharacteristics($char) unless $found;

    return;
}

sub set_material_type {

    my ( $self, $material, $type ) = @_;

    return unless ( $material && $type );

    $material->setMaterialType($type);

    return;
}

sub set_technology_type {

    my ( $self, $assay, $type ) = @_;

    return unless ( $assay && $type );

    # Look through descriptions for a matching OE, or a description
    # holding an OE with the same category.
    my ( $found, $desc );
    if ( my $descs = $assay->getDescriptions() ) {
	foreach my $old ( @$descs ) {
	    if ( my $oes = $old->getAnnotations() ) {
		foreach my $oe ( @$oes ) {

		    # Same category; record the description object.
		    if ( $oe->getCategory() eq $type->getCategory() ) {
			$desc = $old;

			# Same value; we're done here.
			if ( $oe->getValue() eq $type->getValue() ) {
			    $found++;
			}
		    }
		}
	    }
	}
    }

    unless ( $found ) {
	unless ( $desc ) {
	    $desc = Bio::MAGE::Description::Description->new();
	    $assay->addDescriptions( $desc );
	}
	$desc->addAnnotations( $type );
    }

    return;
}

sub add_factorvals_to_bioassays {

    my ( $self, $factorvals, $bioassays ) = @_;

    # Generate a uniqued list of bioassays.
    my %unique_ba = map { $_->getIdentifier() => $_ } @$bioassays;

    # Takes a list of FactorValues and BioAssays, links the former to
    # the latter, checking for duplicates.

    # Add the factors if not already linked.
    foreach my $ba ( values %unique_ba ) {
	foreach my $fv ( @$factorvals ) {
	    $self->add_factorval_to_bioassay( $fv, $ba );
	}
    }

    return;
}

sub add_provider_to_source : PRIVATE {

    my ( $self, $provider, $source ) = @_;

    my $found;
    if ( my $preexisting_people = $source->getSourceContact() ) {

	my $new_id = $provider->getIdentifier();
	$found = first {
	    $_->getIdentifier()     eq $new_id
	}   @$preexisting_people;
    }
    $source->addSourceContact($provider) unless $found;

    return;
}

sub add_description_to_describable : PRIVATE {

    my ( $self, $description, $describable ) = @_;

    my $found;
    if ( my $preexisting_descs = $describable->getDescriptions() ) {

	my $new_text = $description->getText();
	$found = first {
	    $_->getText()     eq $new_text
	}   @$preexisting_descs;
    }
    $describable->addDescriptions($description) unless $found;

    return;
}

sub add_nvt_to_extendable : PRIVATE {

    my ( $self, $nvt, $extendable ) = @_;

    my $found;
    if ( my $preexisting_nvts = $extendable->getPropertySets() ) {

	my $new_name  = $nvt->getName();
	my $new_value = $nvt->getValue();
	$found = first {
	       $_->getName()  eq $new_name
	    && $_->getValue() eq $new_value;
	}   @$preexisting_nvts;
    }
    $extendable->addPropertySets($nvt) unless $found;

    return;
}

sub add_factorvalue_to_factor {

    my ( $self, $fv, $factor ) = @_;

    my $found;
    my $name = $fv->getName();
    if ( my $preexisting_fvs = $factor->getFactorValues() ) {
	if ( my $value = $fv->getValue() ) {
	    my $new_cat = $value->getCategory();
	    my $new_val = $value->getValue();
	    $found = first {
		my $oldvalue = $_->getValue;
		$oldvalue
	     && ($oldvalue->getCategory() eq $new_cat )
	     && ($oldvalue->getValue()    eq $new_val )
	    } @$preexisting_fvs;
	}
	elsif ( my $measurement = $fv->getMeasurement() ) {
	    my $new_val  = $measurement->getValue();
	    my $new_unit = $self->get_unitname_from_measure($measurement);
	    $found = first {
		my $oldmeas = $_->getMeasurement();
		$oldmeas
	    &&  $oldmeas->getValue() eq $new_val
	    && ($self->get_unitname_from_measure($oldmeas) eq $new_unit)
	    } @$preexisting_fvs;
	}
	elsif ( defined $name ) {
	    $found = first {
		$_->getName() eq $name
	    } @$preexisting_fvs;
	}
	else {
	    croak("Error: FactorValue has no value, measurement or name.");
	}
    }

    $factor->addFactorValues($fv) unless $found;

    return;
}

sub get_unitname_from_measure : PRIVATE {

    my ( $self, $measurement ) = @_;

    my $unitname;
    if ( my $unit = $measurement->getUnit() ) {
	$unitname = $self->get_unitname_for_unit( $unit );
    }

    # Return empty string on failure; this value will be used in
    # string comparisons so should not be undef.
    return defined $unitname ? $unitname : q{};
}
    
sub get_unit_for_param : PRIVATE {

    my ( $self, $parameter ) = @_;

    return unless $parameter;

    my $defaultval = $parameter->getDefaultValue();

    if ($defaultval) {
	return $defaultval->getUnit();
    }

    return;
}

sub get_unitname_for_unit : PRIVATE {

    my ( $self, $unit ) = @_;

    return unless $unit;

    my $unitname = $unit->getUnitNameCV();
    if ( ! $unitname || $unitname eq 'other' ) {
	$unitname = $unit->getUnitName() || 'other';
    }
    
    return $unitname;
}

sub create_single_treatment : PRIVATE {

    my ( $self, $app, $bmm, $order, $default_action ) = @_;

    my $action;
    if ( $app ) {

	# Use Storable::dclone to copy the ProtocolType OE and reset
	# the category to Action.
	my $protocol = $app->getProtocol();
	if ( my $type = $protocol->getType() ) {
	    $action = dclone($protocol->getType());
	    $action->setCategory('Action');
	}
    }

    unless ( $action ) {

	# Fall back to a generic default.
	$action = $self->create_ontologyentry(
	    'Action',
	    ($default_action || 'specified_biomaterial_action'),
	);
    }

    # Quick and dirty, we may want to revisit this FIXME
    my $identifier = $self->generate_id_template(
	unique_identifier() . '.Treatment',
    );

    my $treatment = Bio::MAGE::BioMaterial::Treatment->new(
	identifier                    => $identifier,
	action                        => $action,
	order                         => $order,
	sourceBioMaterialMeasurements => [ $bmm ],
    );

    $treatment->setProtocolApplications( [ $app ] ) if $app;

    return $treatment;
}

sub create_material_treatments : PRIVATE {

    my ( $self, $protocolapps, $previous, $default_action ) = @_;

    my @treatments;

    # One BioMaterialMeasurement used for all Treatments.
    my $bmm;
    if ( $previous ) {
	$bmm = Bio::MAGE::BioMaterial::BioMaterialMeasurement->new(
	    bioMaterial => $previous,
	);
    }

    # If ProtocolApps supplied, generate a treatment for each.
    my $order = 1;
    foreach my $app ( @{ $protocolapps } ) {

	my $treatment = $self->create_single_treatment(
	    $app,
	    $bmm,
	    $order,
	);
	$order++;
	push @treatments, $treatment;
    }

    # Fall back to a single treatment if there's no protocol
    # applications, but there is a source material.
    if ( ! scalar( @treatments ) && $bmm ) {
	my $treatment = $self->create_single_treatment(
	    undef,
	    $bmm,
	    1,
	    $default_action,
	);
	push @treatments, $treatment;
    }

    return \@treatments;
}

sub add_treatments_to_material : PRIVATE {

    my ( $self, $treatments, $material ) = @_;

    # FIXME compare old source materials with the new ones, add and
    # maybe renumber the treatment order if possible?

    # Lookup table of treatments by order (NB this is *not* infallible
    # FIXME).
    my %old_treatments = map { $_->getOrder() => $_ }
	@{ $material->getTreatments() || [] };

    foreach my $new ( @$treatments ) {

	# See if we've seen this treatment before. This relies on the
	# object having the same order attribute FIXME.
	if ( my $old = $old_treatments{ $new->getOrder() } ) {
	    $self->update_treatment_info( $old, $new );
	}
	else{
	    $material->addTreatments($new);
	}
    }

    return;
}

sub update_treatment_info : PRIVATE {

    my ( $self, $old, $new ) = @_;

    if ( my $bmms = $new->getSourceBioMaterialMeasurements() ) {
	foreach my $bmm ( @{ $bmms } ) {
	    $self->add_source_to_treatment( $bmm, $old );
	}
    }

    if ( my $apps = $new->getProtocolApplications() ) {
	foreach my $app ( @{ $apps } ) {
	    $self->add_protocolapp_to_treatment( $app, $old );
	}
    }

    return;
}

sub add_source_to_treatment : PRIVATE {

    my ( $self, $source_bmm, $treatment ) = @_;

    my $found;
    if ( my $preexisting_bmms
	     = $treatment->getSourceBioMaterialMeasurements() ) {
	my $new_id = $source_bmm->getBioMaterial()->getIdentifier();
	$found = first {
	    $_->getBioMaterial()->getIdentifier() eq $new_id;
	}   @$preexisting_bmms;
    }
    $treatment->addSourceBioMaterialMeasurements($source_bmm)
	unless $found;

    return;
}

sub add_protocolapp_to_treatment : PRIVATE {

    my ( $self, $protoapp, $treatment ) = @_;

    my $found;
    if ( my $preexisting_apps
	     = $treatment->getProtocolApplications() ) {
	my $new_id = $protoapp->getProtocol()->getIdentifier();
	$found = first {
	    $_->getProtocol()->getIdentifier() eq $new_id;
	}   @$preexisting_apps;
    }
    $treatment->addProtocolApplications($protoapp)
	unless $found;

    return;
}

sub add_images_to_pba : PRIVATE {

    my ( $self, $images, $pba ) = @_;

    my @image_acquisitions;

    # Capture all the ImageAcquisitions attached to $pba
    foreach my $bat ( @{ $pba->getBioAssayTreatments() || [] } ) {
	if ( $bat->isa('Bio::MAGE::BioAssay::ImageAcquisition') ) {
	    push @image_acquisitions, $bat;
	}
    }

    # Create ImageAcquisition if necessary, then add $images to all
    # IAs in the PBA.
    unless ( scalar @image_acquisitions ) {
	my $ia_identifier = $pba->getIdentifier();
	$ia_identifier =~ s/PhysicalBioAssay \z/ImageAcquisition/xms;
	my $ia = Bio::MAGE::BioAssay::ImageAcquisition->new(
	    identifier       => $ia_identifier,
	    target           => $pba,
	    physicalBioAssay => $pba,
	);
	push @image_acquisitions, $ia;
    }

    foreach my $ia ( @image_acquisitions ) {
	foreach my $image ( @$images ) {
	    my $found = first {
		$_->getURI() eq $image->getURI()
	    } @{ $ia->getImages() || [] };
	    $ia->addImages( $image ) unless $found;
	}
    }

    foreach my $image ( @$images ) {
	my $found = first {
	    $_->getURI() eq $image->getURI()
	} @{ $pba->getPhysicalBioAssayData() || [] };
	$pba->addPhysicalBioAssayData( $image ) unless $found;
    }

    return;
}

sub add_basource_to_map : PRIVATE {

    my ( $self, $bioassay, $map ) = @_;

    my $found;
    if ( my $sources = $map->getSourceBioAssays() ) {
	my $new_id = $bioassay->getIdentifier();
	$found = first {
	    $_->getIdentifier() eq $new_id
	} @$sources;
    }
    $map->addSourceBioAssays( $bioassay ) unless $found;

    return;
}
    
sub create_perchannel_pba : PRIVATE {

    my ( $self, $identifier_template, $channelname, $label, $hyb_pba, $scanname ) = @_;

    $channelname ||= 'Unknown';
    my $new_id_template  = "$identifier_template.$channelname";

    # The following convention is assumed when adding FactorValues to
    # all the BioAssays in a row.
    my $channel_pba_name = "$scanname.$channelname";

    # We don't pass $args->{derived_from} down to the extended PBA
    # generation; this is used as a flag to indicate hyb-level PBAs
    # only.
    my $channel_pba = $self->extended_pba_bag(
	$channel_pba_name,
	{
	    identifier_template => $new_id_template,
	    name                => $channel_pba_name,
	    label               => $label,
	},
    );

    # Add a BioAssayTreatment pointing from $hyb_pba to channel PBAs
    # here.
    my %preexisting;
    if ( my $old_treats = $hyb_pba->getBioAssayTreatments() ) {
	foreach my $treat ( @$old_treats ) {
	    if ( my $old_pba = $treat->getPhysicalBioAssay() ) {
		$preexisting{ $old_pba->getIdentifier() }++;
	    }
	}
    }
    unless ( $preexisting{ $channel_pba->getIdentifier() } ) {
	$hyb_pba->addBioAssayTreatments(
	    $self->new_scan(
		{
		    identifier_template => $new_id_template,
		    name                => $channel_pba_name,
		    pba                 => $channel_pba,
		    target              => $channel_pba,
		},
	    )
	);
    }

    return $channel_pba;
}

sub add_dbad_to_dba : PRIVATE {

    my ( $self, $dbad, $dba ) = @_;

    my $found;
    if ( my $preexisting_dbads = $dba->getDerivedBioAssayData() ) {
	my $new_id = $dbad->getIdentifier();
	$found = first { $_->getIdentifier() eq $new_id }
	    @$preexisting_dbads;
    }
    $dba->addDerivedBioAssayData( $dbad ) unless $found;

    return;
}
    
sub add_datafiles : PRIVATE {

    my ( $self, @datafiles ) = @_;

    foreach my $file ( @datafiles ) {
	$datafiles_cache{ ident $self }{ $file->get_path() } = $file;
    }

    return;
} 

sub get_datafiles {

    my ( $self ) = @_;

    # Return sorted alphabetically by name for the moment FIXME.
    return [
	map { $datafiles_cache{ ident $self }{$_} }
        sort keys %{ $datafiles_cache{ ident $self } }
    ];
}

sub get_sdrf_filehandle {

    my ( $self ) = @_;

    unless ( $sdrf_filehandle{ident $self} ) {
	if ( my $file = $self->get_sdrf() ) {
	    open (my $fh, '<', $file)
		or croak("Error opening SDRF for reading: $!\n");
	    $sdrf_filehandle{ident $self} = $fh;
	}
	else {
	    confess("Error: No SDRF filename given.");
	}
    }
    return $sdrf_filehandle{ident $self};
}

sub get_filename : RESTRICTED {

    my ( $self ) = @_;
    
    return $self->get_sdrf();
}
    
sub simplify_single_channels : PRIVATE {

    # Snip out the extra PBAs used for two-colour coding for the
    # single-channel hybs.
    my ( $self ) = @_;

    foreach my $hyb_pba ( @{ $self->pba_bag() } ) {

	next unless ( scalar( @{ $hyb_pba->getChannels() || [] } ) == 1 );

	BAT:
	foreach my $bat ( @{ $hyb_pba->getBioAssayTreatments() || [] } ) {
	    my $ch_pba = $bat->getTarget();

	    # If scans were never generated, we could have just the hyb PBA.
	    next BAT if ( $ch_pba->getIdentifier() eq $hyb_pba->getIdentifier()
			      && $ch_pba->getBioAssayCreation() );

	    my $mrg_pba;
	    if ( my $ch_bats = $ch_pba->getBioAssayTreatments() ) {
		warn ("WARNING: discarding all but first BioAssayTreatment.")
		    if (scalar(@$ch_bats) > 1 );
		if ( scalar(@$ch_bats) ) {
		    $mrg_pba = $ch_bats->[0]->getTarget();
		}
	    }

	    # Repoint the merged PBA data to the hyb PBA. Note that
	    # this overwrites any BATs associated with $hyb_pba; this
	    # was necessary to allow clean deletion of $ch_pba (don't
	    # ask me why; I assume a reference needs weakening
	    # somewhere, presumably in the $hyb_pba BAT).
	    if ( $mrg_pba ) {
		my ($images, $protocolapps, $mbas, $dbas)
		    = $self->strip_pba_for_repointing($mrg_pba);
		$self->repoint_pba_data(
		    $images,
		    $protocolapps,
		    $mbas,
		    $dbas,
		    $hyb_pba,
		    $mrg_pba->getName(),
		);
	    }

	    # Also strip the channel PBA. This appears to remove
	    # references to $mrg_pba.
	    $self->strip_pba_for_repointing($ch_pba);

	    # Delete the old PBA objects from the bags.
	    $self->extended_pba_bag($ch_pba->getName(), 'delete');
#		    or die("Error: Unable to delete unwanted channel PBA: "
#			       . $ch_pba->getName());
	    if ( $mrg_pba ) {
		$self->extended_pba_bag($mrg_pba->getName(), 'delete');
#		    or die("Error: Unable to delete unwanted merging PBA: "
#			       . $mrg_pba->getName());
	    }

	    # We remove the identifiers; this will cause an exception
	    # if there's a problem with these objects hanging around
	    # later (better that than silent failure).
	    $ch_pba->setIdentifier("");
	    $mrg_pba->setIdentifier("") if $mrg_pba;
	}
    }

    return;
}

sub strip_pba_for_repointing : PRIVATE {

    my ( $self, $pba ) = @_;

    my (%oldimages, %oldprotocolapps, %oldmbas, %olddbas);

    # Gather associations from one hyb to be transferred to another.
    
    # Images first.
    foreach my $image ( @{ $pba->getPhysicalBioAssayData() || [] } ) {
	$oldimages{ $image->getIdentifier() } = $image;
    }
    $pba->setPhysicalBioAssayData([]);

    # Process Images associated with the BAT (should be
    # the same, but you never know).
    my $bat = $pba->getBioAssayTreatments()->[0];
    if ( $bat ) {
	if ( $bat->isa('Bio::MAGE::BioAssay::ImageAcquisition') ) {
	    foreach my $image ( @{ $bat->getImages() || [] } ) {
		$oldimages{ $image->getIdentifier() } = $image;
	    }
	}

	# ProtocolApps.
	foreach my $pa ( @{ $bat->getProtocolApplications() || [] } ) {
	    $oldprotocolapps{ $pa } = $pa;
	}
    }

    $pba->setBioAssayTreatments([]);
    
    # MBAs.
    foreach my $mba ( @{ $self->mba_bag() } ) {
	if ( my $fext = $mba->getFeatureExtraction() ) {
	    if ( my $pba_ref = $fext->getPhysicalBioAssaySource() ) {
		if ( $pba_ref->getIdentifier() eq $pba->getIdentifier() ) {
		    $oldmbas{ $mba->getIdentifier() } = $mba;
		}
	    }
	}
    }

    # DBAs (e.g. in the absence of raw data this can happen).
    foreach my $dba ( @{ $self->dba_bag() } ) {
	if ( my $maps = $dba->getDerivedBioAssayMap() ) {
	    foreach my $map ( @$maps ) {
		my @new_sources;
		if ( my $bas = $map->getSourceBioAssays() ) {
		    foreach my $ba ( @$bas ) {
			if ( $ba->getIdentifier() eq $pba->getIdentifier() ) {
			    $olddbas{ $dba->getIdentifier() } = $dba;
			}
			else {
			    push @new_sources, $ba;
			}
		    }
		}

		# Break the link between $pba and map.
		$map->setSourceBioAssays(\@new_sources);
	    }
	}
    }

    $pba->setBioAssayFactorValues([]);
    $pba->setChannels([]);

    return (
	[values %oldimages],
	[values %oldprotocolapps],
	[values %oldmbas],
	[values %olddbas],
    );
}

sub repoint_pba_data : PRIVATE {

    my ( $self,
	 $oldimages,
	 $oldprotocolapps,
	 $oldmbas,
	 $olddbas,
	 $pba,
	 $name ) = @_;

    my $identifier = $self->generate_id_template($name) . '.ImageAcquisition';
    my $bat = Bio::MAGE::BioAssay::ImageAcquisition->new(
	identifier       => $identifier,
	target           => $pba,
	name             => $name,
#	physicalBioAssay => $pba,
    );

    # Reattach any Images moved from old BAT.
    if ( scalar ( @{ $oldimages || [] } ) ) {
	$self->add_images_to_pba( $oldimages, $pba );
    }

    # Reattach old protocolapps from old BAT.
    foreach my $pa ( @{ $oldprotocolapps || [] } ) {
	$self->add_protocolapp_to_treatment( $pa, $bat );
    }

    # Repoint any MBAs previously pointing to $hyb_pba.
    if ( scalar ( @{ $oldmbas || [] } ) ) {
	foreach my $mba ( @$oldmbas ) {
	    my $fext = $mba->getFeatureExtraction();
	    $fext->setPhysicalBioAssaySource($pba);
	}
    }

    # Repoint any DBAs previously pointing to $hyb_pba.
    if ( scalar ( @{ $olddbas || [] } ) ) {
	foreach my $dba ( @$olddbas ) {
	    my $maps = $dba->getDerivedBioAssayMap();
	    foreach my $map ( @$maps ) {
		$self->add_basource_to_map( $pba, $map );
	    }
	}
    }

    $pba->setBioAssayTreatments( [ $bat ] );

    return;
}

sub propagate_fvs_to_datafiles : PRIVATE {

    my ( $self ) = @_;

    FILE:
    foreach my $file ( @{ $self->get_datafiles || [] } ) {

	my $badata;
	next FILE unless ( $badata = $file->get_mage_badata() );

	my $badim;
	next FILE unless ( $badim = $badata->getBioAssayDimension() );

	foreach my $bioassay ( @{ $badim->getBioAssays() || [] } ) {

	    FACTORVALUE:
	    foreach my $fv ( @{ $bioassay->getBioAssayFactorValues() || [] } ) {
		my ( $category, $value );
		if ( my $oe = $fv->getValue() ) {
		    $category = $oe->getCategory();
		    $value    = $oe->getValue();
		}
		elsif ( my $measurement = $fv->getMeasurement() ) {
		    my $unit = $measurement->getUnit();
		    $category = $unit
			      ? ( $unit->getUnitNameCV() || $unit->getUnitName() )
			      : 'UNKNOWN';
		    $value    = $measurement->getValue();
		}
		else {
		    next FACTORVALUE;
		}
		$file->add_factor_value( $category, $value );
	    }
	}
    }

    return;
}

sub add_native_filetypes : PRIVATE {
    my ( $self, %type ) = @_;

    foreach my $filename ( keys %type ) {
        $native_filetypes{ident $self}{$filename} = $type{$filename};
    }
    return $native_filetypes{ident $self};
}

sub get_blank_regexp {

    # Allow access to the RE we're using to detect blanks.
    my ( $self ) = @_;

    return $BLANK;
}

1;

__DATA__

    header:                    material_section(?)
                               edge(s?)
                               assay_or_hyb(?)
                               edge(s?)
                               data_section(?)
                               factor_value(s?)
                               end_of_line

                                   { $return = sub{

                                          my @objects;

                                          # Reset some global variables.
                                          $::channel           = 'Unknown';
                                          $::array_accession   = undef;
                                          $::previous_node     = undef;
                                          @::protocolapp_list  = ();

                                          # Generate the objects.
                                          foreach my $sub (@{$item[1][0]},
                                                           @{$item[2]},
                                                           @{$item[3]},
                                                           @{$item[4]},
                                                           @{$item[5][0]},
                                                           @{$item[6]}){
                                              if (ref $sub eq 'CODE') {
                                                  my @obj = &{ $sub };
                                                  push @objects, @obj;
                                              }
                                              else {
                                                  die("Error: Grammar rule return value not a CODE ref: $sub");
                                              }
                                          }

                                          if ( scalar @_ ) {
                                              die("Error: SDRF row not completely parsed: " . join("\n", @_));
                                          }

                                          # Post-process BioAssays and FactorValues.
                                          my @bioassays
                                              = grep { $_ && $_->isa('Bio::MAGE::BioAssay::BioAssay') }
                                                  @objects;
                                          my @factorvals
                                              = grep { $_ && $_->isa('Bio::MAGE::Experiment::FactorValue') }
                                                  @objects;     
                                          $::sdrf->add_factorvals_to_bioassays(
                                              \@factorvals,
                                              \@bioassays,
                                          );

                                          return \@objects;
                                     };
                                   }

                             | <error: Invalid header; unparseable sequence starts here: $text>

    end_of_line:               <skip:'[ \x{0}\r]*'> /\Z/

    material_section:          material edge_and_material(s?)

                               { $return = [$item[1], map { @{ $_ } } @{$item[2]}] }

    data_section:              assay_or_data edge_and_assay_or_data(s?)

                               { $return = [$item[1], map { @{ $_ } } @{$item[2]}] }

    edge_and_material:         edge(s?) material { $return = [ @{ $item[1] }, $item[2] ] }

    edge_and_assay_or_data:    edge(s?) assay_or_data    { $return = [ @{ $item[1] }, $item[2] ] }

    assay_or_data:             event
                             | data

    edge:                      factor_value
                             | protocol

    material:                  source
                             | sample
                             | extract
                             | labeled_extract

    event:                     scan
                             | normalization

    data:                      raw_data
                             | derived_data

    source_name:               /Source *Names?/i

    source:                    source_name source_attribute(s?)

                                   { $return = sub{
                                          my $name = shift;
                                          my $obj  = $::sdrf->create_source($name);
                                          foreach my $sub (@{$item[2]}){
                                              unshift( @_, $obj ) and
                                                  &{ $sub } if (ref $sub eq 'CODE');  
                                          }
                                          $::previous_node = $obj if $obj;
                                          return $obj; 
                                     };
                                   }

    sample_name:               /Sample *Names?/i

    sample:                    sample_name material_attribute(s?)

                                   { $return = sub{
                                          my $name = shift;
                                          my $obj  = $::sdrf->create_sample(
                                              $name,
                                              $::previous_node,
                                              \@::protocolapp_list,
                                          );
                                          @::protocolapp_list = () if $obj;
                                          foreach my $sub (@{$item[2]}){
                                              unshift( @_, $obj ) and
                                                  &{ $sub } if (ref $sub eq 'CODE');  
                                          }
                                          $::previous_node = $obj if $obj;
                                          return $obj; 
                                     };
                                   }

    extract_name:              /Extract *Names?/i

    extract:                   extract_name material_attribute(s?)

                                   { $return = sub{
                                          my $name = shift;
                                          my $obj  = $::sdrf->create_extract(
                                              $name,
                                              $::previous_node,
                                              \@::protocolapp_list,
                                          );
                                          @::protocolapp_list = () if $obj;
                                          foreach my $sub (@{$item[2]}){
                                              unshift( @_, $obj ) and
                                                  &{ $sub } if (ref $sub eq 'CODE');  
                                          }
                                          $::previous_node = $obj if $obj;
                                          return $obj; 
                                     };
                                   }

    labeled_extract_name:      /Labell?ed *Extract *Names?/i

    labeled_extract:           labeled_extract_name labeled_extract_attribute(s?)

                                   { $return = sub{
                                          my $name = shift;
                                          my $obj  = $::sdrf->create_labeled_extract(
                                              $name,
                                              $::previous_node,
                                              \@::protocolapp_list,
                                          );
                                          @::protocolapp_list = () if $obj;
                                          foreach my $sub (@{$item[2]}){
                                              unshift( @_, $obj ) and
                                                  &{ $sub } if (ref $sub eq 'CODE');  
                                          }
                                          $::previous_node = $obj if $obj;
                                          return $obj; 
                                     };
                                   }

    source_attribute:          material_attribute
                             | provider

    labeled_extract_attribute: material_attribute
                             | label

    material_attribute:        characteristic
                             | materialtype
                             | description
                             | comment

    characteristic_heading:    /Characteristics?/i

    characteristic:            characteristic_heading
                               <skip:' *'> bracket_term
                               <skip:' *\x{0} *'> char_fv_attribute(?)

                                   { $return = sub {
                                         my $material = shift;

                                         my $char;
                                         if ( ref $item[5][0] eq 'CODE' ) {

                                             # Add a unit (nested OE) to the material.
                                             my $oe_meas;
                                             # FIXME we never want to do this now; figure out the MAGE-TAB version
                                             ( $char, $oe_meas )
                                                 = $::sdrf->create_nested_oe_measurement($item[3], shift);
                                             unshift( @_, $oe_meas );
                                             my $unit = &{ $item[5][0] };
                                             $::sdrf->add_char_to_material($char, $material);
                                         }
                                         else {

                                             # Value
                                             my @args = shift;

                                             if ( ref $item[5][0] eq 'ARRAY' ) {

                                                 # Term Source
                                                 push @args, shift;

                                                 # Accession
                                                 push @args, ($item[5][0][1] eq 'term_accession')
                                                             ? shift
                                                             : undef;
                                             }
                                             else {

                                                 # No term source given
                                                 push @args, undef, undef;
                                             }

                                             $char = $::sdrf->create_ontologyentry($item[3], @args);
                                             $::sdrf->add_char_to_material($char, $material);
                                         }
                                         return $char;
                                     };
                                   }

    factor_value_heading:      /Factor *Values?/i

    factor_value:              factor_value_heading
                               <skip:' *'> bracket_term parens_term(?)
                               <skip:' *\x{0} *'> char_fv_attribute(?)

                                   { $return = sub {
                                         my ($fv, $ef);
                                         if ( ref $item[6][0] eq 'CODE' ) {
                                             my $value = shift;

                                             # Attach the unit to the measurement.
                                             unshift( @_, undef );
                                             my $unit = &{ $item[6][0] };

                                             ($fv, $ef) = $::sdrf->create_factorvalue_measurement(
                                                 $item[3],
                                                 $item[4][0],
                                                 $value,
                                                 $unit,
                                             );

                                             # This has to be done after adding the unit.
                                             $::sdrf->add_factorvalue_to_factor( $fv, $ef ) if $fv;
                                         }
                                         else {

                                             # Value
                                             my @args = shift;

                                             if ( ref $item[6][0] eq 'ARRAY' ) {

                                                 # Term Source
                                                 push @args, shift;

                                                 # Accession
                                                 push @args, ($item[6][0][1] eq 'term_accession')
                                                             ? shift
                                                             : undef;
                                             }
                                             else {

                                                 # No term source given
                                                 push @args, undef, undef;
                                             }
                                             $fv = $::sdrf->create_factorvalue_value(
                                                 $item[3],
                                                 $item[4][0],
                                                 @args,
                                             );
                                         }
                                         return $fv;
                                     };
                                   }

    char_fv_attribute:         unit
                             | termsource

    bracket_term:              /\A \[ [ ]* ([^\x{0}\]]+?) [ ]* \]/xms

                                   { $return = $1 }

    parens_term:               /\A \( [ ]* ([^\x{0}\)]+?) [ ]* \)/xms

                                   { $return = $1 }

    namespace_term:            /\A : ([^\x{0}]+)/xms

                                   { $return = $1 }

    term_source_ref:           /Term *Source *REFs?/i

    termsource:                term_source_ref
                               <skip:' *'> namespace_term(?)
                               <skip:' *\x{0} *'> term_accession(?)

                                   { $return = [ $item[3][0], $item[5][0] ] } # FIXME add namespace_term support

    term_accession:            /Term *Accession *Numbers?/i

                                   { $return = 'term_accession'; }

    provider_heading:          /Providers?/i

    provider:                  provider_heading comment(s?)

                                   { $return = sub {
                                         my $source = shift;
                                         my @names  = split /\s*;\s*/, shift;

                                         $source->set_providers( \@names );

# FIXME we attach comments to the source, rather than the provider (model problem FIXME? or at least remove comments from the production.)
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $source ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');
                                         }

                                         return @names;
                                     };
                                   }

    materialtype_heading:      /Material *Types?/i

    materialtype:              materialtype_heading termsource(?)

                                   { $return = sub {
                                         my $material = shift;

                                         # Value
                                         my @args = shift;

                                         if ( ref $item[2][0] eq 'ARRAY' ) {

                                             # Term Source
                                             push @args, shift;

                                             # Accession
                                             push @args, ($item[2][0][1] eq 'term_accession')
                                                         ? shift
                                                         : undef;
                                         }
                                         else {

                                             # No term source given
                                             push @args, undef, undef;
                                         }
                                         my $type = $::sdrf->create_ontologyentry('MaterialType', @args);
                                         $::sdrf->set_material_type( $material, $type ) if ($material && $type);
                                         return $type;
                                     };
                                   }

    label_heading:             /Labels?/i

    label:                     label_heading termsource(?)

                                   { $return = sub {
                                         my $labeled_extract = shift;
                                         $::channel = shift;

                                         my @args;

                                         if ( ref $item[2][0] eq 'ARRAY' ) {

                                             # Term Source
                                             push @args, shift;

                                             # Accession
                                             push @args, ($item[2][0][1] eq 'term_accession')
                                                         ? shift
                                                         : undef;
                                         }
                                         else {

                                             # No term source given
                                             push @args, undef, undef;
                                         }
                                         my $label = $::sdrf->create_label($::channel, @args, $labeled_extract);
                                         return $label;
                                     };
                                   }

    description:               /Descriptions?/i

                                   { $return = sub {
                                         my $describable = shift;
                                         return $::sdrf->create_description(shift, $describable);
                                     };
                                   }

    comment_heading:           /Comments?/i

    comment:                   comment_heading <skip:' *'> bracket_term

                                   { $return = sub {
                                         my $extendable = shift;
                                         return $::sdrf->create_nvt($item[3], shift, undef, $extendable);
                                     };
                                   }

    protocol_ref:              /Protocol *REFs?/i

    protocol:                  protocol_ref
                               <skip:' *'> namespace_term(?)
                               <skip:' *\x{0} *'> termsource(?)
                               protocol_attributes(s?)

                                   { $return = sub{

                                          # Name, namespace_term
                                          my @args = (shift, $item[3][0]);

                                          if ( ref $item[5][0] eq 'ARRAY' ) {

                                              # Term Source
                                              push @args, shift;

                                              # Accession
                                              push @args, ($item[5][0][1] eq 'term_accession')
                                                          ? shift
                                                          : undef;
                                          }
                                          else {

                                              # No term source given
                                              push @args, undef, undef;
                                          }

                                          my $obj  = $::sdrf->create_protocolapplication(@args);

                                          # Add to the global ProtApp list immediately so that
                                          # parameter units can be sorted out without
                                          # having to pass $obj through.
#                                          push(@::protocolapp_list, $obj) if $obj;

                                          foreach my $sub (@{$item[6]}){
                                              unshift( @_, $obj ) and
                                                  &{ $sub } if (ref $sub eq 'CODE');  
                                          }
                                          return $obj; 
                                     };
                                   }

    protocol_attributes:       parameter
                             | performer
                             | date
                             | comment

    parameter_heading:         /Parameter *Values?/i

    parameter:                 parameter_heading
                               <skip:' *'> bracket_term
                               <skip:' *\x{0} *'> parameter_attributes(s?)

                                   { $return = sub {
                                         my $protocolapp = shift;
                                         my $value       = shift;
                                         my $obj = $::sdrf->create_parametervalue($item[3], $value, $protocolapp);
                                         foreach my $sub (@{$item[5]}){
                                             if ( ref $sub eq 'CODE' ) {

                                                  # Unit, Comment
                                                  unshift( @_, $obj );
                                                  my $attr = &{ $sub };

                                                  if ( defined $attr
                                                      && $attr->isa('Bio::MAGETAB::ControlledTerm') ) {
                                                      $::sdrf->add_unit_to_thing( $attr, $obj->get_measurement() );
                                                  }
                                             }
                                             elsif ( ref $sub eq 'ARRAY' ) {

# FIXME OE as adjunct to parameter not supported by MAGE-TAB model.
# At the moment (v1.1 DRAFT) it seems that OE is not required, but
# we'll keep this here in case that ever changes.

                                                 warn("ControlledTerm not supported for ParameterValue.");

#                                                 # Value
#                                                 my @args;
#
#                                                 # Term Source
#                                                 push @args, shift;
#
#                                                 # Accession
#                                                 push @args, ($sub->[1] eq 'term_accession')
#                                                             ? shift
#                                                             : undef;
#
#                                                 $::sdrf->add_value_to_parameter(
#                                                     $obj,
#                                                     @args,
#                                                 );
                                             }
                                         }
                                         return $obj;
                                     };
                                   }

    parameter_attributes:      unit
                             | termsource
                             | comment

    unit_heading:              /Unit/i

    unit:                      unit_heading
                               <skip:' *'> bracket_term
                               <skip:' *\x{0} *'> termsource(?)

                                   { $return = sub {

                                         # Unit name
                                         my @args = shift;

                                         if ( ref $item[5][0] eq 'ARRAY' ) {

                                             # Term Source
                                             push @args, shift;

                                             # Accession
                                             push @args, ($item[5][0][1] eq 'term_accession')
                                                         ? shift
                                                         : undef;
                                         }
                                         else {

                                             # No term source given
                                             push @args, undef, undef;
                                         }

                                         my $unit = $::sdrf->create_unit(
                                             $item[3],
                                             @args,
                                         );

                                         return $unit;
                                     };
                                   }

    performer_heading:         /Performers?/i

    performer:                 performer_heading comment(s?)

                                   { $return = sub {
                                         my $protocolapp = shift;
                                         my @names       = split /\s*;\s*/, shift;

                                         $protocolapp->set_performers( \@names );

# FIXME we attach comments to the protocolapp, rather than the performer (model problem FIXME? or at least remove comments from the production.)
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $protocolapp ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');
                                         }

                                         return @names;
                                     };
                                   }

    date:                      /Dates?/i

                                   { $return = sub {
                                         my $protocolapp = shift;
                                         my $date        = shift;
                                         $protocolapp->set_date( $date );
                                         return $date;
                                     };
                                   }

    array_design:              array_design_file
                             | array_design_ref

    array_design_file_heading: /Array *Design *Files?/i

    array_design_file:         array_design_file_heading comment(s?)

                                   { die "ADFs not yet supported" }

    array_design_ref_heading:  /Array *Design *REFs?/i

    array_design_ref:          array_design_ref_heading
                               <skip:' *'> namespace_term(?)
                               <skip:' *\x{0} *'> termsource(?)
                               comment(s?)

                                   { $return = sub {
                                         my $hybridization  = shift;
                                         $::array_accession = shift;

                                         # array_accession, namespace_term
                                         my @args = ( $::array_accession, $item[3][0] );

                                         if ( ref $item[5][0] eq 'ARRAY' ) {

                                             # Term Source
                                             push @args, shift;

                                             # Accession
                                             push @args, ($item[5][0][1] eq 'term_accession')
                                                         ? shift
                                                         : undef;
                                         }
                                         else {

                                             # No term source given
                                             push @args, undef, undef;
                                         }

                                         my $obj = $::sdrf->create_array(@args, $hybridization);
                                         foreach my $sub (@{$item[6]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }
                                         return $obj;
                                     };
                                   }

    assay_or_hyb:              assay
                             | hybridization

    hybridization_name:        /Hybridi[sz]ation *Names?/i

    hybridization:             hybridization_name hybrid_attribute(s?)

                                   { $return = sub {
                                         my $name = shift;
                                         my $obj  = $::sdrf->create_hybridization(
                                             $name,
                                             $::previous_node,
                                             \@::protocolapp_list,
                                             $::channel,
                                         );
                                         @::protocolapp_list = () if $obj;
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }
                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                      };
                                    }

    hybrid_attribute:          array_design
                             | technology_type
                             | comment

    assay_name:                /Assay *Names?/i

    assay:                     assay_name technology_type comment(?)

                                   { $return = sub {
                                         my $name = shift;
                                         my $obj  = $::sdrf->create_assay(
                                             $name,
                                             $::previous_node,
                                             \@::protocolapp_list,
                                             $::channel,
                                         );
                                         @::protocolapp_list = () if $obj;
                                         foreach my $sub ($item[2], $item[3][0]){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }

                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                      };
                                    }

    technol_type_heading:      /Technology *Types?/i

    technology_type:           technol_type_heading termsource(?)

                                   { $return = sub {
                                         my $assay = shift;

                                         # Value
                                         my @args = shift;

                                         if ( ref $item[2][0] eq 'ARRAY' ) {

                                             # Term Source
                                             push @args, shift;

                                             # Accession
                                             push @args, ($item[2][0][1] eq 'term_accession')
                                                         ? shift
                                                         : undef;
                                         }
                                         else {

                                             # No term source given
                                             push @args, undef, undef;
                                         }
                                         my $type = $::sdrf->create_technology_type( $assay, @args );
                                         return $type;
                                     };
                                   }

    scan_name:                 /Scan *Names?/i

    scan:                      scan_name scan_attribute(s?)

                                   { $return = sub {
                                         my $name = shift;
                                         my $obj = $::sdrf->create_scan(
                                             $name,
                                             $::previous_node,
                                             \@::protocolapp_list,
                                         );
                                         @::protocolapp_list = () if $obj;

                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }

                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                      };
                                    }

    scan_attribute:            comment

    normalization_name:        /Normali[sz]ation *Names?/i

    normalization:             normalization_name norm_attribute(s?)

                                   { $return = sub {
                                         my $obj = $::sdrf->create_normalization(
                                             shift,
                                             $::previous_node,
                                             \@::protocolapp_list,
                                         );
                                         @::protocolapp_list = @{ $apps || [] } if $obj;
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }
                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                     };
                                   }

    norm_attribute:            comment

    raw_data:                  image
                             | array_data
                             | array_data_matrix

    derived_data:              derived_array_data
                             | derived_array_data_matrix

    array_data_file:           /Array *Data *Files?/i

    array_data:                array_data_file comment(s?)

                                   { $return = sub {
                                         my $obj = $::sdrf->create_data_file(
                                             shift,
                                             $::previous_node,
                                             \@::protocolapp_list,
                                         );
                                         @::protocolapp_list = () if $obj;
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }
                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                     };
                                   }

    derived_array_data_file:   /Derived *Array *Data *Files?/i

    derived_array_data:        derived_array_data_file comment(s?)

                                   { $return = sub {
                                         my $obj = $::sdrf->create_data_file(
                                             shift,
                                             $::previous_node,
                                             \@::protocolapp_list,
                                         );
                                         @::protocolapp_list = () if $obj;
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }
                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                     };
                                   }

    array_data_matrix_file:    /Array *Data *Matrix *Files?/i

    array_data_matrix:         array_data_matrix_file comment(s?)

                                   { $return = sub {
                                         my $obj = $::sdrf->create_data_matrix(
                                             shift,
                                             $::previous_node,
                                             \@::protocolapp_list,
                                         );
                                         @::protocolapp_list = () if $obj;
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }
                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                     };
                                   }

    derived_array_data_matrix_file: /Derived *Array *Data *Matrix *Files?/i

    derived_array_data_matrix: derived_array_data_matrix_file comment(s?)

                                   { $return = sub {
                                         my $obj = $::sdrf->create_data_matrix(
                                             shift,
                                             $::previous_node,
                                             \@::protocolapp_list,
                                         );
                                         @::protocolapp_list = () if $obj;
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }
                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                     };
                                   }

    image_file:                /Image *Files?/i

    image:                     image_file comment(s?)

                                   { $return = sub {
                                         my $obj = $::sdrf->create_data_file(
                                             shift,
                                             $::previous_node,
                                             \@::protocolapp_list,
#                                             $::channel,
#                                             $::previous_material,
                                         );
                                         foreach my $sub (@{$item[2]}){
                                             unshift( @_, $obj ) and
                                                 &{ $sub } if (ref $sub eq 'CODE');  
                                         }
                                         $::previous_node = $obj if $obj;
                                         return $obj;
                                     };
                                   }

