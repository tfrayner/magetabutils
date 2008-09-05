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

BEGIN {
    use_ok( 'Bio::MAGETAB::Util::Reader::IDF' );
}

sub test_parse {

    my ( $idf ) = @_;

    $idf->parse();

    return $idf->get_magetab_object();
}

sub check_term {

    my ( $cat, $val, $attr, $inv, $ts, $builder ) = @_;

    my $method = "get_$attr";

    my $ct;
    lives_ok( sub { $ct = $builder->get_controlled_term({
        category => $cat,
        value    => $val,
    }) }, "Builder returns a $cat term" );
    is( $ct->get_termSource(), $ts, 'with the correct termSource' );
    is_deeply( $inv->$method(), $ct, 'ArrayDesign $attr set correctly' );

    return;
}

my $idf;

# Instantiate with none of the required attributes.
dies_ok( sub{ $idf = Bio::MAGETAB::Util::Reader::IDF->new() },
         'instantiation without attributes' );

# Populate our temporary test IDF file.
my ( $fh, $filename ) = tempfile();
while ( my $line = <DATA> ) {
    print $fh $line;
}

# FIXME or just close the fh here?
seek ( $fh, 0, 0 ) or die("Error seeking in temporary filehandle.");

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
#TODO: {
#    local $TODO = 'designElements are unordered so this test fails.';
    is_deeply( $inv, $inv2, 'investigation objects agree' );
#}

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

Term Source Name	RO
Term Source File	http://www.random-ontology.org/file.obo
Term Source Version	0.1  
