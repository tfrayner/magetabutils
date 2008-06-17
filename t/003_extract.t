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
    use_ok( 'Bio::MAGETAB::Extract' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::ControlledTerm;
use Bio::MAGETAB::Measurement;
use Bio::MAGETAB::SDRFRow;

my $ct = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test' );
my $me = Bio::MAGETAB::Measurement->new( type => 'test', value => 'test' );

my %required_attr = (
    name           => 'test',
);

my %optional_attr = (
    type            => $ct,
    characteristics => [ $ct ],
    measurements    => [ $me ],
);

my %bad_attr = (
    name            => [],
    type            => 'test',
    characteristics => [ 'test' ],
    measurements    => 'test',
);

my $ct2 = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test 2' );
my $me2 = Bio::MAGETAB::Measurement->new( type => 'test', value => 'test' );

my %secondary_attr = (
    name            => 'test2',
    type            => $ct2,
    characteristics => [ $ct2 ],
    measurements    => [ $me2 ],
);

my $obj = test_class(
    'Bio::MAGETAB::Extract',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::Material'), 'object has correct superclass' );

my $row  = Bio::MAGETAB::SDRFRow->new( nodes => [ $obj ] );
my $ex3  = Bio::MAGETAB::Extract->new( name  => 'test extract 3' );
my $row2 = Bio::MAGETAB::SDRFRow->new( nodes => [ $ex3 ] );

# Test reciprocal relationship between nodes and sdrfRows.
is_deeply( [ $obj->get_sdrfRows() ], [ $row ],
           'initial state prior to reciprocity test' );
is_deeply( $row->get_nodes(), $obj, 'sets nodes in target sdrfRow' );
lives_ok( sub{ $obj->set_sdrfRows( [ $row2 ] ) }, 'setting sdrfRows via self' );
is_deeply( [ sort $obj->get_nodes() ], [ sort $row, $row2 ], 'adds nodes to self' );
