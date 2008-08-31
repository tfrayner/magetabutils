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
# $Id: 002_builder.t 1050 2008-08-18 23:27:32Z tfrayner $

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;
use File::Temp qw(tempfile);

#use Bio::MAGETAB;

BEGIN {
    use_ok( 'Bio::MAGETAB::Util::Reader::ADF' );
}

sub test_parse {

    my ( $adf ) = @_;

    # FIXME to test: parse, parse_body, parse_header.
    $adf->parse();

    return $adf->magetab_object();
}

my $adf;

# Instantiate with none of the required attributes.
dies_ok( sub{ $adf = Bio::MAGETAB::Util::Reader::ADF->new() },
         'instantiation without attributes' );

# Populate our temporary test ADF file.
my ( $fh, $filename ) = tempfile();
while ( my $line = <DATA> ) {
    print $fh $line;
}

# FIXME or just close the fh here?
seek ( $fh, 0, 0 ) or die("Error seeking in temporary filehandle.");

# Test parsing.
lives_ok( sub{ $adf = Bio::MAGETAB::Util::Reader::ADF->new( uri => $filename ) },
          'instantiation with uri attribute' );
my $ad = test_parse( $adf );

# Test parsing into a supplied magetab_object.
use Bio::MAGETAB::ArrayDesign;
my $ad2 = Bio::MAGETAB::ArrayDesign->new( name => 'Dummy array design for testing',
                                          uri  => $filename );

lives_ok( sub{ $adf = Bio::MAGETAB::Util::Reader::ADF->new( uri            => $filename,
                                                            magetab_object => $ad2, ) },
          'instantiation uri and magetab_object attributes' );

# These really ought to look identical.
is_deeply( $ad, $ad2, 'array design objects agree' );

# FIXME test with bad ADF input (unrecognized headers etc.)

__DATA__
[header]
# FIXME we want more headings here, but also keep this comment!
Array Design Name	Test array design

[main]
# FIXME more columns needed here also.
Block Column	Block Row	Column	Row	Reporter Name	Reporter Sequence
1	1	1	1	Test1	ATGC
1	1	1	2	Test2	ATGC
    
