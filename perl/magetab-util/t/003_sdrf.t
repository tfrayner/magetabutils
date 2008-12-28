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
    use_ok( 'Bio::MAGETAB::Util::Reader::SDRF' );
}

sub add_dummy_objects {

    my ( $builder ) = @_;

    foreach my $tsname ( 'NCI META', 'MO', 'ArrayExpress' ) {
        $builder->find_or_create_term_source({ name => $tsname });
    }
    foreach my $adname ( 'A-TEST-1' ) {
        $builder->find_or_create_array_design({ name => $adname });
    }
    foreach my $efname ( 'EF1', 'EF2' ) {
        $builder->find_or_create_factor({ name => $efname });
    }
    my %proto = (
        'EXTPRTCL10654'  => 'Extracted Product',
        'TRANPRTCL10656' => '',
    );
    while ( my ( $protoname, $param ) = each %proto ) {
        my $p = $builder->find_or_create_protocol({ name => $protoname });
        $builder->find_or_create_protocol_parameter({ name => $param, protocol => $p }) if $param;
    }

    return;
}

my $sdrf_reader;

# Instantiate with none of the required attributes.
dies_ok( sub{ $sdrf_reader = Bio::MAGETAB::Util::Reader::SDRF->new() },
         'instantiation without attributes' );

# Populate our temporary test SDRF file.
my ( $fh, $filename ) = tempfile( UNLINK => 1 );
while ( my $line = <DATA> ) {
    print $fh $line;
}

# Close the filehandle, since we'll be using the filename only.
close( $fh ) or die("Error closing filehandle: $!");

# Test parsing.
lives_ok( sub{ $sdrf_reader = Bio::MAGETAB::Util::Reader::SDRF->new( uri => $filename ) },
          'instantiation with uri attribute' );
my $builder;
lives_ok( sub { $builder = $sdrf_reader->get_builder(); }, 'SDRF parser returns a Builder object' );
is( ref $builder, 'Bio::MAGETAB::Util::Builder', 'of the correct class' );

add_dummy_objects( $builder );

my $sdrf;
lives_ok( sub { $sdrf = test_parse( $sdrf_reader ) }, 'parsing completes without exceptions' );

# Test parsing into a supplied magetab_object.
use Bio::MAGETAB::SDRF;
my $sdrf2 = Bio::MAGETAB::SDRF->new( uri => $filename );

lives_ok( sub{ $sdrf_reader = Bio::MAGETAB::Util::Reader::SDRF->new( uri            => $filename,
                                                                     magetab_object => $sdrf2, ) },
          'parser instantiates with uri and magetab_object attributes' );

#########
# These tests take a long time to run and don't really contribute much.
#add_dummy_objects( $sdrf_reader->get_builder() );
#test_parse( $sdrf_reader );

# These two sets of parse results really ought to look identical.
#is_deeply( $sdrf, $sdrf2, 'SDRF objects agree' );
#########

# FIXME (IMPORTANT!) check the output against what we expect!

# FIXME test with bad SDRF input (unrecognized headers etc.)

__DATA__
Source Name	Provider	Characteristics[ OrganismPart ]	Characteristics[DiseaseState]	Term Source REF:test namespace	Term Accession Number	Material Type	Description	Comment[MyNVT]	Sample Name	Characteristics[Age]	Unit[TimeUnit]	Term Source REF	Material Type	Comment[sample comment]	Protocol REF	Performer	Parameter Value[Extracted Product]	Date	Comment[P_COMM]	Extract Name	Material Type	LabeledExtract Name	MaterialType	Term Source REF	Label	Term Source REF	Protocol REF	Term Source REF	Hybridization Name	Comment[some comment about the hyb]	Array Design REF	Comment[some comment about the array]	Protocol REF:made-up namespace:	Scan Name	Image File	Comment [scan comment here]	Array Data File	Comment[raw data comment]	Protocol REF	Normalization Name	Comment[data smoothness]	Derived Array Data File	Factor Value [EF1](Prognosis)	Term Source REF	Term Accession Number	Factor Value [EF2]	Unit[ConcentrationUnit]	Term Source REF
my source	the guy in the next room	root	hemophilia	NCI META	CL:111111	organism_part	description_text	mycomment	my sample	6	hours	MO	cell	sample comment value	EXTPRTCL10654	the guy in the next room	total RNA	2007-02-21	This did not happen. I was not here.	my extract	not_a_MO_term	my LE1	total_RNA	MO	Cy3	MO	P-XMPL-7	ArrayExpress	my hybridization	hyb conditions were suboptimal	A-TEST-1	My favourite array design	scanning protocol	my scan	imagefile1.TIFF	this was a great picture	Data1.txt		TRANPRTCL10656	my norm	high	NormData1.txt	ill	NCI META	CL:0123345	10	mg_per_mL	MO
my source	the guy in the next room	root	hemophilia	NCI META	CL:111111	organism_part	description_text	mycomment	my sample	6	hours	MO	cell	sample comment value	EXTPRTCL10654	the guy in the next room	total RNA	2007-02-21	This did not happen. I was not here.	my extract	not_a_MO_term	my LE2	total_RNA	MO	Cy5	MO	P-XMPL-7	ArrayExpress	my hybridization	hyb conditions were suboptimal	A-TEST-1	My favourite array design	scanning protocol	my scan	imagefile1.TIFF	this was a great picture	Data2.txt	not as good as the picture	TRANPRTCL10656	my norm	low	NormData2.txt	healthy	NCI META	CL:2347689	0	mg_per_mL	MO
sparse source 1			normal		blah blah ignore me										EXTPRTCL10654		polyA RNA					sparse LE Cy5			Cy5		P-XMPL-11	ArrayExpress	sparse hyb		A-TEST-1			sparse scan1	testing.jpg		Data3.txt		TRANPRTCL10656	norm 3		NormData3.txt	pained expression					
sparse source 2			normal												EXTPRTCL10654		polyA RNA					sparse LE Cy3			Cy3		P-XMPL-11	ArrayExpress	sparse hyb		A-TEST-1			sparse scan2			Data4.txt		TRANPRTCL10656	norm 3		NormData3.txt	pregnant pause					
sparse source 3			normal												EXTPRTCL10654		polyA RNA					sparse LE biotin			biotin		P-XMPL-11	ArrayExpress	sparse hyb b		A-TEST-1		scanning protocol	sparse scan3	imagefile2.TIFF	a bit blurry			TRANPRTCL10656	norm 4		NormData4.txt	preternatural calm					
