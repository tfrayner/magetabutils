#!/usr/bin/env perl
#
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

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::SDRF' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Normalization;
use Bio::MAGETAB::SDRFRow;

my $norm = Bio::MAGETAB::Normalization->new( name => 'test norm' );
my $row  = Bio::MAGETAB::SDRFRow->new( nodes => [ $norm ] );

my %required_attr = (
    uri            => 'file://localhost/data/sdrf1.txt',
);

my %optional_attr = (
    sdrfRows       => [ $row ],
);

my %bad_attr = (
    sdrfRows       => 'test',
    uri            => [],
);

my $norm2 = Bio::MAGETAB::Normalization->new( name => 'test norm 2' );
my $row2  = Bio::MAGETAB::SDRFRow->new( nodes => [ $norm2 ] );

my %secondary_attr = (
    sdrfRows       => [ $row, $row2 ],
    uri            => 'file://localhost/data/sdrf2.txt',
);

my $obj = test_class(
    'Bio::MAGETAB::SDRF',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
