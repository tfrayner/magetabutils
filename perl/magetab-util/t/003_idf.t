#!/usr/bin/env perl
#
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
# $Id: 003_adf.t 1117 2008-09-04 20:46:03Z tfrayner $

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;
use File::Temp qw(tempfile);

use lib 't/testlib';
use CommonTests qw( test_parse check_term );

BEGIN {
    use_ok( 'Bio::MAGETAB::Util::Reader::IDF' );
}

my $idf;

# Instantiate with none of the required attributes.
dies_ok( sub{ $idf = Bio::MAGETAB::Util::Reader::IDF->new() },
         'instantiation without attributes' );

# Populate our temporary test IDF file.
my ( $fh, $filename ) = tempfile( UNLINK => 1 );
while ( my $line = <DATA> ) {
    print $fh $line;
}

# Close the filehandle, since we'll be using the filename only.
close( $fh ) or die("Error closing filehandle: $!");

# Test parsing.
lives_ok( sub{ $idf = Bio::MAGETAB::Util::Reader::IDF->new( uri => $filename ) },
          'instantiation with uri attribute' );
my $inv = test_parse( $idf );

# Test parsing into a supplied magetab_object.
use Bio::MAGETAB::Investigation;
my $inv2 = Bio::MAGETAB::Investigation->new( title => 'Dummy investigation for testing' );

lives_ok( sub{ $idf = Bio::MAGETAB::Util::Reader::IDF->new( uri            => $filename,
                                                            magetab_object => $inv2, ) },
          'instantiation uri and magetab_object attributes' );
test_parse( $idf );

# These really ought to look identical.
is_deeply( $inv, $inv2, 'investigation objects agree' );

# FIXME (IMPORTANT!) check the output against what we expect!
my $builder;
lives_ok( sub { $builder = $idf->get_builder(); }, 'IDF parser returns a Builder object' );
is( ref $builder, 'Bio::MAGETAB::Util::Reader::Builder', 'of the correct class' );

# Check that the term source was created.
my $ts;
lives_ok( sub { $ts = $builder->get_term_source({
    name => 'RO',
}) }, 'Builder returns a term source' );
is( $ts->get_name(),    'RO',  'with the correct name' );
is( $ts->get_version(), '0.1', 'and the correct version' );
is( $ts->get_uri(), 'http://www.random-ontology.org/file.obo', 'and the correct uri' );

# FIXME test with bad IDF input (unrecognized headers etc.)

__DATA__
Investigation Title	Dummy title
# This is a comment to be ignored.
Experimental Design	dummy_design
Experimental Design Term Source REF	RO
Experimental Factor Name	DUMMYFACTOR
Experimental Factor Type	dummy_factor
Experimental Factor Term Source REF	RO
Person Last Name	Bannister
Person First Name	Bruce
Person Mid Initials	B
Person Email	greenmeanie@bannister.com
Person Phone	01 234 5678
Person Fax	01 234 6789
Person Address	Arkansas, USA
Person Affiliation	Projects-R-Us
Person Roles	investigator
Person Roles Term Source REF	RO
Quality Control Type	poor
Quality Control Term Source REF	RO
Replicate Type	few
Replicate Term Source REF	RO
Normalization Type	none
Normalization Term Source REF	RO
Date of Experiment	2008-09-04
Public Release Date	2009-09-04
PubMed ID	1234567
Publication DOI	doi:10.1186/1471-2105-7-489
Publication Author List	Joe Schmoe, John Q. Public, Joseph Bloggs, Bruce Bannister
Publication Title	How to make friends and influence government officials
Publication Status	not published
Publication Status Term Source REF	RO
Experiment Description	not a real experiment
Protocol Name	how to extract DNA
Protocol Type	nucleic_acid_extraction
Protocol Description	blah blah blah
Protocol Parameters	strength; duration
Protocol Hardware	big expensive machine
Protocol Software	correspondingly expensive proprietary junk
Protocol Contact	random string here
Protocol Term Source REF	RO
SDRF File	dummy.txt
Term Source Name	RO
Term Source File	http://www.random-ontology.org/file.obo
Term Source Version	0.1  
