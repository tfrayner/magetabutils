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
    use_ok( 'Bio::MAGETAB::Feature' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Reporter;

my $rp = Bio::MAGETAB::Reporter->new( name => 'test reporter' );

my %required_attr = (
    blockColumn => 1,
    blockRow    => 2,
    column      => 3,
    row         => 4,
    reporter    => $rp,
);

my %optional_attr = (
);

my %bad_attr = (
    blockColumn => {},
    blockRow    => [],
    column      => 'x',
    row         => [],
    reporter    => 'test',
);

my $rp2 = Bio::MAGETAB::Reporter->new( name => 'test reporter 2' );

my %secondary_attr = (
    blockColumn => 12,
    blockRow    => 22,
    column      => 32,
    row         => 42,
    reporter    => $rp2,
);

my $obj = test_class(
    'Bio::MAGETAB::Feature',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::DesignElement'), 'object has correct superclass' );
