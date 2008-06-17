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
# $Id: 003_sdrf.t 900 2008-05-13 13:07:43Z tfrayner $

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::SDRFRow' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Normalization;
use Bio::MAGETAB::Extract;

my $norm = Bio::MAGETAB::Normalization->new( name => 'test norm' );

my %required_attr = (
    nodes          => [ $norm ],
);

my %optional_attr = (
    rowNumber      => 10,
);

my %bad_attr = (
    nodes          => 'test',
    rowNumber      => 'test',
);

my $norm2 = Bio::MAGETAB::Normalization->new( name => 'test norm 2' );

my %secondary_attr = (
    nodes          => [ $norm, $norm2 ],
    rowNumber      => 23,
);

my $obj = test_class(
    'Bio::MAGETAB::SDRFRow',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );

my $ex2 = Bio::MAGETAB::Extract->new( name => 'test extract 2' );
my $ex3 = Bio::MAGETAB::Extract->new( name => 'test extract 3' );

# Test reciprocal relationship between nodes and sdrfRows.
is_deeply( [ sort $obj->get_nodes() ], [ sort $norm, $norm2 ],
           'initial state prior to reciprocity test' );
lives_ok( sub{ $obj->set_nodes( [ $ex2 ] ) }, 'setting nodes via self' );
is_deeply( $ex2->get_sdrfRows(), $obj, 'sets sdrfRows in target node' );
lives_ok( sub{ $ex3->set_sdrfRows( [ $obj ] ) }, 'setting sdrfRows via target node' );
is_deeply( [ sort $obj->get_nodes() ], [ sort $ex2, $ex3 ], 'adds nodes to self' );
